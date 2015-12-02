package starlingExtensions.interfaces
{
import starling.animation.IAnimatable;

public interface IMovieClip extends IAnimatable
	{
		function play():void
		function stop():void
		function autoPlayClip():void
		function pause():void
		function resume():void
		function get currentFrame():int
		function set currentFrame(value:int):void
	}
}