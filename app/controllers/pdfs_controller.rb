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
    @pdf = Pdf.find_by_id!(params[:id])

    render 'public/index'
  end

  def query
    @pdf = Pdf.find_by_id!(params[:id])

    @question = params[:question]
    @answer = QueryPdfService.new(@pdf, @question).run!

    render 'public/index'
  end

  protected

  def create_pdf_params
    params.require(:pdf).permit(:original_file)
  end
end
