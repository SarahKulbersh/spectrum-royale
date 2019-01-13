package com.unhurdle.spectrum
{
	COMPILE::JS{
    import org.apache.royale.html.util.addElementToWrapper;
    import org.apache.royale.core.WrappedHTMLElement;
  }
	[Event(name="change", type="org.apache.royale.events.Event")]

  public class Slider extends SliderBase
  {
    public function Slider()
    {
      super();
    }
    override protected function getSelector():String{
      return "spectrum-Slider";
    }
    override public function addedToParent():void{
			super.addedToParent();
			positionElements();
    }

    override protected function positionElements():void{
        var percent:Number = this.value / (max - min) * 100;
        handle.style.left = percent + "%";
        // Set initial track position
        leftTrack.style.width = percent + '%';
        rightTrack.style.width = (100 - percent) + '%';
    }
    private function handleChange():void{
			// if(valueNode){
			// 	valueNode.text = "" + value;
			// }
    }

		override protected function enableDisableInput(value:Boolean):void{
			input.disabled = value;
		}


    public function get value():Number
    {
    	return Number(input.value);
    }

    public function set value(value:Number):void
    {
			//TODO why is this a string?
			input.value = "" + value;
			if(parent){
				positionElements();
			}
			if(valueNode){
				valueNode.text = "" + value;
			}

    }



		override protected function getValue():String{
			// override in subclass
			return input.value;
		}    
    
    private var _filled:Boolean;

    public function get filled():Boolean
    {
    	return _filled;
    }

    public function set filled(value:Boolean):void
    {
    	_filled = value;
        toggle(valueToSelector("filled"),value);
    }

    private var _ticks:int;

    public function get ticks():int
    {
    	return _ticks;
    }

    public function set ticks(value:int):void
    {
        if(value != _ticks){
            var base:String = getSelector();
        	_ticks = value;
            if(!tickContainer){
                tickContainer = newElement("div", base + "-ticks");
                controlsContainer.insertBefore(tickContainer,handle);
            } else {
                tickContainer.innerHTML = "";
            }
            tickArray = [];
            for(var i:int=0;i<value;i++){
                var tick:HTMLElement = newElement("div",base + "-tick");
                var node:TextNode = new TextNode("div");
                node.className = base + "-tickLabel";
                tick.appendChild(node.element);
                tickArray.push(node);
                tickContainer.appendChild(tick);
            }
            if(_showTickValues){
                calculateTickValues();
            }

        }

    }

    private var tickArray:Array;

    private var _showTickValues:Boolean;

    public function get showTickValues():Boolean
    {
    	return _showTickValues;
    }

    public function set showTickValues(value:Boolean):void
    {
    	_showTickValues = value;
        calculateTickValues();
    }
    private function calculateTickValues():void{
        if(!tickArray || !tickArray.length){
            return;
        }
        if(_showTickValues){
            // don't bother figuring this out if we're not showing them
            var numTicks:Number = tickArray.length;
            var minVal:Number = min;
            var maxVal:Number = max;
            var span:Number = maxVal - minVal;
            var increment:Number = span/numTicks;
        }
        for(var i:int=0;i<numTicks;i++){
            if(_showTickValues){
                tickArray[i].text = "" + minVal;
                minVal = Math.round((minVal + increment) * 100)/100;
            } else {
                tickArray[i].text = "";
            }
        }
    }

    private var tickContainer:HTMLElement;
    private var handle:HTMLElement;
	private var leftTrack:HTMLElement;
  	private var rightTrack:HTMLElement;
		
	COMPILE::JS
    override protected function createElement():WrappedHTMLElement{
        /**
         <div class="spectrum-Slider-controls">
            <div class="spectrum-Slider-track"></div>
            <div class="spectrum-Slider-handle" style="left: 40%;">
            <input type="range" class="spectrum-Slider-input" value="14" step="2" min="10" max="20">
            </div>
            <div class="spectrum-Slider-track"></div>
        </div>
        */
        var elem:WrappedHTMLElement = addElementToWrapper(this,'div');
        controlsContainer = newElement("div",appendSelector("-controls"));
        //first track
				leftTrack = newElement("div",appendSelector("-track"));
        controlsContainer.appendChild(leftTrack);
        
        //handle
        handle = newElement("div",appendSelector("-handle"));
        input = newElement("input",appendSelector("-input")) as HTMLInputElement;
        input.type = "range";
				input.step = "1";
        input.onchange = handleChange();
        handle.appendChild(input);
        controlsContainer.appendChild(handle);

        //second track
				rightTrack = newElement("div",appendSelector("-track"));
        controlsContainer.appendChild(rightTrack);

        elem.appendChild(controlsContainer);
    		element.addEventListener('mousedown', onMouseDown);
        return elem;
    }
		// Element interaction
		override protected function onMouseMove(e:MouseEvent):void {
            var elem:HTMLElement = element as HTMLElement;
			var sliderOffsetWidth:Number = elem.offsetWidth;
			var sliderOffsetLeft:Number = elem.offsetLeft + (elem.offsetParent as HTMLElement).offsetLeft;

			var x:Number = Math.max(Math.min(e.x-sliderOffsetLeft, sliderOffsetWidth), 0);
			var percent:Number = (x / sliderOffsetWidth) * 100;
			var val:Number = (max-min) / (100/percent);
			var stepVal:Number = step;
			var rem:Number = val % stepVal;
			val = val - rem;
			if (rem > (stepVal/2)){
		    val += stepVal;
			}
			value = val;
			// value = Math.round(val * 10000)/10000;
    }


/**
TODO
For video player there are additional buffer elements. It probably makes sense to add a separate component for that...
<div class="spectrum-Slider">
  <div class="spectrum-Slider-labelContainer">
    <label class="spectrum-Slider-label" id="spectrum-Slider-label-16" for="spectrum-Slider-input-16">My Video</label>
    <div class="spectrum-Slider-value">3:48</div>
  </div>
  <div class="spectrum-Slider-controls">
    <div class="spectrum-Slider-track"></div>
    <div class="spectrum-Slider-buffer" style="width: 20%;" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="50" aria-labelledby="spectrum-Slider-label-16"></div>
    <div class="spectrum-Slider-handle" style="left: 20%;">
      <input type="range" class="spectrum-Slider-input" aria-valuetext="3:48" value="228" min="0" max="760" id="spectrum-Slider-input-16">
    </div>
    <div class="spectrum-Slider-buffer" style="left: 20%; width: 30%;"></div>
    <div class="spectrum-Slider-track"></div>
  </div>
</div>

 */
  }
}