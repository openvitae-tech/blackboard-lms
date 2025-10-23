# frozen_string_literal: true

class FfmpegService
  include Singleton
  def extract_audio(input_path)
    audio_io = StringIO.new
    cmd = [
      'ffmpeg',
      '-i', input_path,
      '-vn',
      '-acodec', 'libmp3lame',
      '-f', 'mp3',
      '-'
    ]

    Open3.popen3(*cmd) do |_stdin, stdout, _stderr, wait|
      audio_io.write(stdout.read)
      wait.value
    end

    audio_io.rewind
    audio_io
  end
end
