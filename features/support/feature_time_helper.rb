module FeatureTimeHelper
  def parse_slot_time(date_str, time_str)
    # Try flexible parsing in app timezone, then try adding current year as fallback
    t = Time.zone.parse("#{date_str} #{time_str}") rescue nil
    t ||= Time.zone.parse("#{date_str} #{Time.zone.now.year} #{time_str}") rescue nil
    raise "Could not parse slot time #{date_str} #{time_str}" unless t
    t
  end
end

World(FeatureTimeHelper)