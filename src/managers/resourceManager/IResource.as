package managers.resourceManager
{
	public interface IResource
	{
		function refreshSource(url:String,refreshWaitStack:Boolean=false):void
	}
}