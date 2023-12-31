# frozen_string_literal: true

require 'pdf-reader'
require 'tokenizers'
require 'openai'

class GenerateSectionsService
  EMBEDDING_MODEL = 'text-embedding-ada-002'

  def initialize(pdf)
    @pdf = pdf
  end

  def run!
    # Extract the text from each page of the PDF.
    document_text = ''
    @pdf.original_file.blob.open do |tempfile|
      reader = PDF::Reader.new(tempfile.path)

      reader.pages.each_with_index do |page, index|
        page_number = index + 1
        Rails.logger.info "Processing page #{page_number} of #{reader.page_count}"

        document_text += page.text if page.text.present?
      end
    end

    # Naively split the document into paragraphs. There is room for improvement
    # here, as it could result in chunks being too big or (more likely) too small.
    # See https://community.openai.com/t/reasonable-text-length-for-embedding/34055
    sections = []
    tokenizer = Tokenizers.from_pretrained('gpt2')
    document_text.split(/\n\n\n/).each_with_index do |text, index|
      # split and join are used to replace any whitespace (space, newlines, etc)
      # with a single space character
      content = text.split.join(' ')

      # skip paragraphs with no content
      next if content.blank?

      # Estimate the number of tokens
      token_count = tokenizer.encode(content).tokens.length

      sections << {
        title: "Paragraph #{index}",
        content:,
        token_count:
      }
    end

    # Send each section to OpenAI to get the embeddings
    openai = OpenAI::Client.new
    sections_with_embeddings = sections.map do |section|
      embeddings = get_embedding(openai, section[:content], section[:token_count])

      section.merge({
                      embeddings:
                    })
    rescue StandardError => e
      Rails.logger.warn "Error generating embeddings for section: #{e.message}"
      section.merge({
                      embeddings: []
                    })
    end

    @pdf.sections = sections_with_embeddings.to_json
    @pdf.save!
  end

  protected

  def get_embedding(client, text, token_count)
    Rails.logger.info "OpenAI embeddings request: #{token_count} tokens"
    response = client.embeddings(
      parameters: {
        model: EMBEDDING_MODEL,
        input: text
      }
    )
    response.dig('data', 0, 'embedding')
  end
end
