class Channel::BuildStatisticsJob
  @queue = :normal

  def self.perform(options = {})
    channel = Channel.find(options['channel_id'])
    raise "チャンネル「#{channel.title}」の統計取得に失敗しました。" unless channel.build_statistics

    Rails.logger.info("チャンネル「#{channel.title}」の統計取得が終了しました。")
  end
end