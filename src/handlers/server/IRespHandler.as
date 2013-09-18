package handlers.server
{
	

	/**
	 * 处理服务器传回的应答
	 * 
	 * @author fangc
	 */
	public interface IRespHandler
	{
		function handleResp(action:String, params:Array):void;
	}
}