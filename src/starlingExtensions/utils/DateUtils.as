package starlingExtensions.utils
{
	public class DateUtils
	{
		public function DateUtils()
		{
		}
		public static function get UTC():Number
		{
			var d:Date = new Date();
			
			return Date.UTC(d.fullYear,d.month,d.date,d.hours,d.minutes,d.seconds,d.milliseconds);
		}
		public static function get UTC_SECONDS():Number
		{
			return Math.round(UTC/1000);
		}
	}
}