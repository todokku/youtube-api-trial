class ChannelsController < ApplicationController
  helper_method :sort_column, :sort_direction

  before_action :set_channel, only: [
    :show, :destroy, :build_statistics, :update_snippet
  ]
  before_action -> {require_data(channels_url, Channel)},
                only: [:build_all_statistics, :update_all_snippets]
  authorize_resource

  def index
    @search_channel = search_condition
    @channels = @search_channel.search

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @channel_statistics = @channel.channel_statistics.paginate(
      per: params[:statics_per], page: params[:statics_page]
    )
    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
    @channel = Channel.new
  end

  def create
    @channel = Channel.new(channel_params)

    respond_to do |format|
      if @channel.save_and_set_job
        format.html {redirect_to @channel, notice: t('helpers.notice.create')}
        format.json {render :show, status: :created, location: @channel}
      else
        format.html {render :new}
        format.json {render json: @channel.errors, status: :unprocessable_entity}
      end
    end
  end

  def destroy
    @channel.destroy
    respond_to do |format|
      format.html {redirect_to channels_url, notice: t('helpers.notice.delete')}
      format.json {head :no_content}
    end
  end

  def build_statistics
    JobUtils.enqueue(Channel::BuildStatisticsJob, 'channel_id' => @channel.id)
    respond_to do |format|
      format.html {redirect_to @channel, notice: t('text.channel.build_statistics.start')}
      format.js {render 'partials/toastr', locals: {message: t('text.channel.build_statistics.start')}}
    end
  end

  def build_all_statistics
    JobUtils.enqueue(Channel::BuildAllStatisticsJob)
    respond_to do |format|
      format.html {redirect_to channels_url, notice: t('text.channel.build_all_statistics.message')}
      format.js {render 'partials/toastr', locals: {message: t('text.channel.build_all_statistics.message')}}
    end
  end

  def update_snippet
    JobUtils.enqueue(Channel::UpdateSnippetJob, 'channel_id' => @channel.id)
    respond_to do |format|
      format.html {redirect_to @channel, notice: t('text.channel.update_snippet.start')}
      format.js {render 'partials/toastr', locals: {message: t('text.channel.update_snippet.start')}}
    end
  end

  def update_all_snippets
    JobUtils.enqueue(Channel::UpdateAllSnippetsJob)
    respond_to do |format|
      format.html {redirect_to channels_url, notice: t('text.channel.update_all_snippets.message')}
      format.js {render 'partials/toastr', locals: {message: t('text.channel.update_all_snippets.message')}}
    end
  end

  protected

  def take_params
    super.merge(
      search_channel: search_params
    )
  end

  private

  def set_channel
    @channel = Channel.find(params[:id])
  end

  def channel_params
    params.require(:channel).permit(:channel_id)
  end

  def search_params
    ret = params.permit(:order, :direction)
    ret.merge(params.fetch(:search_channel, {}).permit(:title, :per))
  end

  def search_condition
    cond = Search::Channel.new(search_params)
    cond.per ||= params[:per] || Channel::DEFAULT_PER
    cond.page = params[:page]
    cond
  end

  def sort_column
    params[:order] || 'subscriber_count'
  end

  def sort_direction
    %w(asc desc).include?(params[:direction]) ? params[:direction] : 'desc'
  end
end
