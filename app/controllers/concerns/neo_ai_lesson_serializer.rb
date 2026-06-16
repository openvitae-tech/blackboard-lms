# frozen_string_literal: true

module NeoAiLessonSerializer
  def serialize_lesson(data)
    scenes = (data['scenes'] || []).map { |s| serialize_scene(s) }
    verified = data['verified'] == true
    video_url = data['video_url']
    {
      id: data['id'],
      title: data['title'],
      description: data['description'],
      summary: data['summary'],
      estimated_duration: data['estimated_duration'],
      video_url: video_url,
      verified: verified,
      status: derive_lesson_status(scenes, verified: verified),
      scenes: scenes
    }
  end

  def serialize_scene(data)
    {
      id: data['id'],
      timestamp: data['timestamp'],
      duration: data['duration'],
      visual: data['visual'],
      narration: data['narration'],
      status: data['status'],
      video_url: data['video_url'],
      thumbnail_url: data['thumbnail_url']
    }
  end

  def derive_lesson_status(scenes, verified:)
    return 'WAITING' if scenes.empty?
    return 'VERIFIED' if verified
    return 'VIDEO_READY' if scenes.all? { |s| s[:video_url].present? }

    'PENDING'
  end
end
