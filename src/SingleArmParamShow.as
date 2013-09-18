package
{
	import flash.display.Sprite;
	
	import fl.controls.Label;
	import fl.controls.TextInput;
	
	public class SingleArmParamShow extends Sprite
	{
		
		public var ownerSide:int = 0;
		public var contentSupplyType:int = 0;
		
		private var hp:Label = new Label;
		private var hpValue:TextInput = new TextInput;
		
		private var damage:Label = new Label;
		private var damageValue:TextInput = new TextInput;
		
		private var widthLabel:Label = new Label;
		private var widthLabelValue:TextInput = new TextInput;
		
		private var heightLabel:Label = new Label;
		private var heightLabelValue:TextInput = new TextInput;
		
		public function SingleArmParamShow()
		{
			super();
			
			this.addChild(hp);
			hp.x = 0;
			hp.y = 0;
			hp.text = "hp: ";
			this.addChild(hpValue);
			hpValue.x = 25;
			hpValue.y = 0;
			hpValue.width = 30;
			
			this.addChild(damage);
			damage.x = 60;
			damage.y = 0;
			damage.text = "damage: ";
			this.addChild(damageValue);
			damageValue.x = 110;
			damageValue.y = 0;
			damageValue.width = 30;
			
			this.addChild(widthLabel);
			widthLabel.x = 150;
			widthLabel.y = 0;
			widthLabel.text = "width: ";
			this.addChild(widthLabelValue);
			widthLabelValue.x = 190;
			widthLabelValue.y = 0;
			widthLabelValue.width = 30;
			
			this.addChild(heightLabel);
			heightLabel.x = 220;
			heightLabel.y = 0;
			heightLabel.text = "height: ";
			this.addChild(heightLabelValue);
			heightLabelValue.x = 260;
			heightLabelValue.y = 0;
			heightLabelValue.width = 30;
		}
	}
}