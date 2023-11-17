# frozen_string_literal: true

class QueryPdfService
  # TODO: DRY this and get_embedding is repeated in generate sections service
  EMBEDDING_MODEL = 'text-embedding-ada-002'
  MAX_SECTIONS = 10

  CHAT_MODEL = 'gpt-3.5-turbo'
  CHAT_MAX_TOKENS = 1024

  def initialize(pdf, question)
    @pdf = pdf
    @question = question
  end

  def run!
    # Strip excess whitespace and add a question mark if the question doesn't have one as the last character
    @question = "#{@question.split.join(' ')}?" if @question.last != '?'

    # Generate an embedding for the question
    openai = OpenAI::Client.new
    question_embedding = get_embedding(openai, @question)

    # Map over the sections, and calculate similarity to question, then rank them
    sections_with_ranking = @pdf.sections.map do |section|
      similarity = calculate_similarity(question_embedding, section['embeddings'])

      section.merge({
                      similarity:
                    })
    end

    ranked_sections = sections_with_ranking.sort_by { |section| section[:similarity] }.reverse

    prompt = [
      'You are an analyst. Review the document below and try to answer the best you can the answer given. If the document does not have a specific answer to this question, please analyse it and answer as best you can. The answer should be between 3 and 5 sentences in length.',
      '',
      "QUESTION: #{@question}",
      '',
      'DOCUMENT:'
    ]

    # Take the top N sections, and add them to the prompt
    ranked_sections.first(MAX_SECTIONS).map do |section|
      prompt << section['content']
    end

    prompt = prompt.join("\n")

    query_chat(openai, prompt)
  end

  protected

  def get_embedding(client, text)
    Rails.logger.info "OpenAI embeddings request. #{text.size} characters"
    response = client.embeddings(
      parameters: {
        model: EMBEDDING_MODEL,
        input: text
      }
    )
    response.dig('data', 0, 'embedding')
  end

  def query_chat(client, prompt)
    Rails.logger.info "OpenAI chat request. #{prompt.size} characters"
    response = client.chat(
      parameters: {
        model: CHAT_MODEL,
        max_tokens: CHAT_MAX_TOKENS,
        messages: [{ role: 'user', content: prompt }],
        temperature: 0.4
      }
    )
    response.dig('choices', 0, 'message', 'content')
  end

  # Source https://gist.github.com/DDimitris/694d9da40f8e91326008f8b270afad2a
  def calculate_similarity(vector_a, vector_b)
    return 0 unless vector_a.is_a? Array
    return 0 unless vector_b.is_a? Array
    return 0 if vector_a.size != vector_b.size

    dot_product = 0
    vector_a.zip(vector_b).each do |v1i, v2i|
      dot_product += v1i * v2i
    end
    a = vector_a.map { |n| n**2 }.reduce(:+)
    b = vector_b.map { |n| n**2 }.reduce(:+)
    dot_product / (Math.sqrt(a) * Math.sqrt(b))
  end
end
