package handlers.server
{
	import animator.enginetool.HashMap;
		
	/**
	 * 处理服务器应答的基本类
	 * 
	 * @author fangc
	 */
	public class BaseRespHandler implements IRespHandler
	{
		protected var funs:HashMap = new HashMap();
		
		public function BaseRespHandler()
		{
			this.initActionHandlers();
		}
		protected function initActionHandlers():void
		{
		}
		
		public function handleResp(action:String, params:Array):void
		{
			var fun:Function = this.funs.get(action) as Function;
			if( fun != null )
			{
				fun(params);			
			}
			else
			{
				trace("action:" + action + " is not found");
			}
		}
		

	}
}