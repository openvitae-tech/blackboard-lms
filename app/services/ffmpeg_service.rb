# frozen_string_literal: true

class FfmpegService
  include Singleton
  def extract_audio(input_path)
    raise ArgumentError, 'Input path is required' if input_path.blank?
    raise ArgumentError, 'Input file does not exist' unless File.exist?(input_path)
    raise ArgumentError, 'Input file is not readable' unless File.readable?(input_path)

    audio_io = StringIO.new
    cmd = [
      'ffmpeg',
      '-i', input_path,
      '-vn',
      '-acodec', 'libmp3lame',
      '-f', 'mp3',
      '-'
    ]

    Open3.popen3(*cmd) do |_stdin, stdout, stderr, wait|
      audio_io.write(stdout.read)
      status = wait.value
      unless status.success?
        raise "FFmpeg command failed with status #{status.exitstatus}: #{stderr.read}"
      end
    end

    audio_io.rewind
    audio_io
  end
end
