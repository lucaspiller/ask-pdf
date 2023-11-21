# frozen_string_literal: true

class PdfsController < ApplicationController
  def create
    pdf = Pdf.new(create_pdf_params)

    if pdf.save
      GenerateSectionsJob.perform_later(pdf)
      redirect_to pdf_path(pdf)
    else
      render :new
    end
  end

  def show
    @pdf = Pdf.find_by!(id: params[:id])
  end

  def query
    @pdf = Pdf.find_by!(id: params[:id])

    @question = params[:question]
    @answer = QueryPdfService.new(@pdf, @question).run! do |chunk, answer|
      Turbo::StreamsChannel.broadcast_append_to(
        @pdf,
        target: 'answer',
        partial: 'pdfs/answer_inner',
        locals: { answer: answer }
      )
    end
  end

  protected

  def create_pdf_params
    params.require(:pdf).permit(:original_file)
  end
end
