require_relative '../test_helper'

class TimeExtensionsTest < Minitest::Test
  def setup
    @time = Time.new(2026, 6, 15, 14, 30, 45) # Sunday
    @weekday = Time.new(2026, 6, 16, 9, 0, 0)  # Monday
    @saturday = Time.new(2026, 6, 20, 9, 0, 0) # Saturday
    @sunday = Time.new(2026, 6, 21, 9, 0, 0)   # Sunday
  end

  # ---------- days_seconds ----------

  def test_days_seconds
    t = Time.new(2026, 6, 15, 1, 2, 3)
    assert_equal 1 * 3600 + 2 * 60 + 3, t.days_seconds
  end

  def test_days_seconds_midnight
    t = Time.new(2026, 6, 15, 0, 0, 0)
    assert_equal 0, t.days_seconds
  end

  def test_days_seconds_end_of_day
    t = Time.new(2026, 6, 15, 23, 59, 59)
    assert_equal 23 * 3600 + 59 * 60 + 59, t.days_seconds
  end

  # ---------- beginning_of_day ----------

  def test_beginning_of_day
    result = @time.beginning_of_day
    assert_equal Time.new(2026, 6, 15, 0, 0, 0), result
  end

  def test_beginning_of_day_preserves_date
    assert_equal @time.year,  @time.beginning_of_day.year
    assert_equal @time.month, @time.beginning_of_day.month
    assert_equal @time.day,   @time.beginning_of_day.day
  end

  # ---------- end_of_day ----------

  def test_end_of_day
    result = @time.end_of_day
    assert_equal Time.new(2026, 6, 15, 23, 59, 59), result
  end

  def test_end_of_day_preserves_date
    assert_equal @time.year,  @time.end_of_day.year
    assert_equal @time.month, @time.end_of_day.month
    assert_equal @time.day,   @time.end_of_day.day
  end

  # ---------- at ----------

  def test_at
    result = @time.at(10, 20, 30)
    assert_equal Time.new(2026, 6, 15, 10, 20, 30), result
  end

  def test_at_preserves_date
    result = @time.at(0, 0, 0)
    assert_equal @time.year,  result.year
    assert_equal @time.month, result.month
    assert_equal @time.day,   result.day
  end

  # ---------- all_day ----------

  def test_all_day_returns_range
    assert_kind_of Range, @time.all_day
  end

  def test_all_day_begin
    assert_equal @time.beginning_of_day, @time.all_day.first
  end

  def test_all_day_end
    assert_equal @time.end_of_day, @time.all_day.last
  end

  def test_all_day_includes_noon
    noon = Time.new(2026, 6, 15, 12, 0, 0)
    assert @time.all_day.include?(noon)
  end

  # ---------- add_days ----------

  def test_add_days
    result = @time.add_days(3)
    assert_equal Time.new(2026, 6, 18, 14, 30, 45), result
  end

  def test_add_days_zero
    assert_equal @time, @time.add_days(0)
  end

  def test_add_days_crosses_month
    result = Time.new(2026, 6, 30, 0, 0, 0).add_days(1)
    assert_equal 7, result.month
    assert_equal 1, result.day
  end

  # ---------- subtract_days ----------

  def test_subtract_days
    result = @time.subtract_days(5)
    assert_equal Time.new(2026, 6, 10, 14, 30, 45), result
  end

  def test_subtract_days_zero
    assert_equal @time, @time.subtract_days(0)
  end

  def test_subtract_days_crosses_month
    result = Time.new(2026, 6, 1, 0, 0, 0).subtract_days(1)
    assert_equal 5, result.month
    assert_equal 31, result.day
  end

  def test_add_and_subtract_roundtrip
    assert_equal @time, @time.add_days(7).subtract_days(7)
  end

  # ---------- closest_future_working_day ----------

  def test_closest_future_working_day_from_weekday
    # Monday — already a working day, should not advance
    assert_equal @weekday, @weekday.closest_future_working_day
  end

  def test_closest_future_working_day_from_saturday
    result = @saturday.closest_future_working_day
    assert_equal 1, result.wday # Monday
    assert_equal 22, result.day
  end

  def test_closest_future_working_day_from_sunday
    result = @sunday.closest_future_working_day
    assert_equal 1, result.wday # Monday
    assert_equal 22, result.day
  end

  def test_closest_future_working_day_not_weekend
    result = @saturday.closest_future_working_day
    refute [0, 6].include?(result.wday)
  end

  # ---------- with_current_time ----------

  def test_with_current_time_preserves_date
    result = @time.with_current_time
    assert_equal @time.year,  result.year
    assert_equal @time.month, result.month
    assert_equal @time.day,   result.day
  end

  def test_with_current_time_uses_current_hours
    result = @time.with_current_time
    now = Time.now
    assert_in_delta now.hour, result.hour, 1
    assert_in_delta now.min,  result.min,  1
  end

  # ---------- class methods ----------

  def test_today_is_time
    assert_kind_of Time, Time.today
  end

  def test_today_is_roughly_now
    assert_in_delta Time.now.to_i, Time.today.to_i, 2
  end

  def test_tomorrow_is_one_day_ahead
    assert_in_delta Time.today.to_i + 86_400, Time.tomorrow.to_i, 2
  end

  def test_yesterday_is_one_day_behind
    assert_in_delta Time.today.to_i - 86_400, Time.yesterday.to_i, 2
  end

  def test_beginning_of_today
    t = Time.beginning_of_today
    assert_equal 0, t.hour
    assert_equal 0, t.min
    assert_equal 0, t.sec
    assert_equal Time.now.day, t.day
  end

  def test_end_of_today
    t = Time.end_of_today
    assert_equal 23, t.hour
    assert_equal 59, t.min
    assert_equal 59, t.sec
    assert_equal Time.now.day, t.day
  end

  def test_start_of_today_equals_beginning_of_today
    assert_equal Time.beginning_of_today, Time.start_of_today
  end

  def test_beginning_and_end_of_today_same_date
    b = Time.beginning_of_today
    e = Time.end_of_today
    assert_equal b.year,  e.year
    assert_equal b.month, e.month
    assert_equal b.day,   e.day
  end
end
