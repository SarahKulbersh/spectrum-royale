package com.unhurdle.spectrum
{
  COMPILE::JS{
    import org.apache.royale.html.util.addElementToWrapper;
    import org.apache.royale.core.WrappedHTMLElement;
  }

  import com.unhurdle.spectrum.const.IconType;
  import org.apache.royale.html.util.getLabelFromData;
  import org.apache.royale.collections.IArrayList;
  import com.unhurdle.spectrum.data.MenuItem;
  import org.apache.royale.events.MouseEvent;
  import org.apache.royale.events.Event;
  import org.apache.royale.geom.Rectangle;
  import org.apache.royale.utils.DisplayUtils;
  import org.apache.royale.utils.callLater;
	// import com.unhurdle.spectrum.data.IMenuItem;
	import com.unhurdle.spectrum.const.IconPrefix;
	import com.unhurdle.spectrum.data.IMenuItem;
	import org.apache.royale.events.KeyboardEvent;
	import org.apache.royale.events.utils.EditingKeys;
  /**
   * TODO maybe add flexible with styling of min-width: 0;width:auto;
   */
	[Event(name="change", type="org.apache.royale.events.Event")]
	[Event(name="showMenu", type="org.apache.royale.events.Event")]
  public class Picker extends SpectrumBase
  {
    /**
     * <inject_html>
     * <link rel="stylesheet" href="assets/css/components/picker/dist.css">
     * </inject_html>
     * 
     */
    public function Picker()
    {
      super();
    }
    override protected function getSelector():String{
      return "spectrum-Picker";
    }
    private var _button:FieldButton;
    public function get button():FieldButton{
    	return _button;
    }
    COMPILE::JS
    override protected function createElement():WrappedHTMLElement{
      var elem:WrappedHTMLElement = super.createElement();
      _button = new FieldButton();
      _button.labelClass = appendSelector("-label");
      _button.className = appendSelector("-trigger");
      _button.addEventListener("click",toggleDropdown);
      var type:String = IconType.CHEVRON_DOWN_MEDIUM;
      _button.icon = Icon.getCSSTypeSelector(type);
      _button.iconType = type;
      _button.iconClass = appendSelector("-icon");
      // _button.textNode.element.style.maxWidth = '85%';
      addElement(_button);
      popover = new ComboBoxList();
      popover.className = appendSelector("-popover");
      popover.addEventListener("openChanged",handlePopoverChange);
      // popover.percentWidth = 100;
      // popover.style = {"z-index":100};//????
      // menu = new Menu();
      // popover.addElement(menu);
      menu.addEventListener("change", handleListChange);
      menu.percentWidth = 100;
      popover.style = {"z-index": "2"};
      return elem;
    }
    public var popover:ComboBoxList;
    private function get menu():Menu{
      return popover.list;
    }
    private function handlePopoverChange(ev:Event):void{
      _button.selected = popover.open;
      toggle("is-open",popover.open);
    }
    private function positionPopup():void{
      var minHeight:Number = _minMenuHeight + 6;
      // Figure out direction and max size
      var appBounds:Rectangle = DisplayUtils.getScreenBoundingRect(Application.current.initialView);
      var componentBounds:Rectangle = DisplayUtils.getScreenBoundingRect(this);
      var spaceToBottom:Number = appBounds.bottom - componentBounds.bottom;
      var spaceToTop:Number = componentBounds.top - appBounds.top;
      var spaceOnBottom:Boolean = spaceToBottom >= spaceToTop;
      var pxStr:String = "px";
      switch(_position)
      {
        case "top":
          if(spaceToTop >= minHeight || !spaceOnBottom){
            positionPopoverTop(appBounds.bottom - componentBounds.top,spaceToTop);
          } else {
            positionPopoverBottom(componentBounds,spaceToBottom);

          }
          break;
        default:
          if(spaceToBottom >= minHeight || spaceOnBottom){
            positionPopoverBottom(componentBounds,spaceToBottom);
          } else {
            positionPopoverTop(appBounds.bottom - componentBounds.top,spaceToTop);
          }
          break;
      }
      var leftSpace:Number = componentBounds.x;
      var rightSpace:Number = appBounds.width - (componentBounds.x + componentBounds.width);
      if(rightSpace < leftSpace){
        popover.setStyle("right",rightSpace + "px");
        popover.setStyle("left",null);
      } else {
        popover.setStyle("right",null);
        popover.setStyle("left",leftSpace + "px");
      }
      if(isNaN(_popupWidth)){
        popover.setStyle("minWidth",width + "px");
        // popover.width = width;
      }
    }

    private function toggleDropdown(ev:*):void{
      ev.preventDefault();
      var open:Boolean = !popover.open;
      toggle("is-open",open);
      if(open){
        positionPopup();
        dispatchEvent(new Event("showMenu"));
				callLater(openPopup)
      } else {
        closePopup();
      }
    }

    private var valuesArr:Object;
    private var ind:Number = 0;

    private function selectValue(type:String):void{
      if(valuesArr.length && valuesArr.length > 1){
        var len:int = valuesArr.length;
        for(var index:int = 0; index < len; index++){
          if(valuesArr[index].disabled || valuesArr[index].isDivider){
            continue;
          }
          var t:String = valuesArr[index].text;
          if(_button.text && t.indexOf(_button.text) == 0){
            switch(type)
            {
              case "ArrowDown":
                ind = index + 1;
                while(ind < len && (valuesArr[ind].disabled || valuesArr[ind].isDivider)){
                  ind++;
                }
                break;
              case "ArrowUp":
                if(ind == -1){
                  ind = len;
                }
                ind = index - 1;
                while(ind >= 0 && (valuesArr[ind].disabled || valuesArr[ind].isDivider)){
                  ind--;
                }
                break;
            }
            break;
          }
        }
        if(ind == -1){
          ind = valuesArr.length - 1;
          while(ind >= 0 && (valuesArr[ind].disabled || valuesArr[ind].isDivider)){
            ind--;
          }
        }else if(ind == valuesArr.length){
          ind = 0;
          while(ind < len && (valuesArr[ind].disabled || valuesArr[ind].isDivider)){
            ind++;
          }
        }
        selectedIndex = ind;
      }
    }

    private function changeValue(event:KeyboardEvent):void{
      var key:String = event.key;
      switch(key)
      {
        case "ArrowDown":
        case "ArrowUp":
          event.preventDefault();
          selectValue(key);
          break;
        default:
          if (key.length > 1 && key != EditingKeys.BACKSPACE) {
              return;// do nothing
          }
          if(validText(key)){
            updateValue(key);
          }
          break;
      }
    }

    private function validText(text:String):Boolean{
      return ((text >= "a" && text <= "z") || (text >= "A" && text <="Z") || (text >= "0" && text <= "9"));
    }

    private var provider:Object;
    private function updateValue(text:String):void{
      var arr:Array = [];
      if(!provider || dataProvider.length > provider.length){
        provider = dataProvider;
      }else{
        dataProvider = provider;
      }
      valuesArr = [];
      if(_button.text == "Select a Country with a very long label, too long in fact"){
        if(text == EditingKeys.BACKSPACE){
          text = "";
        }
        _button.text = text;
      }else{
        if(text == EditingKeys.BACKSPACE){
          if(_button.text){
            _button.text = _button.text.slice(0,_button.text.length - 1);
          }
          text = "";
        }
        _button.text += text;
      }
      if(!_button.text){
        selectedIndex = -1;
      }
      valuesArr.push(_button.text);
      var len:int = dataProvider.length;
      for(var index:int = 0; index < len; index++){
        var t:String = dataProvider[index].text;
        if(t && t.toLowerCase().indexOf(_button.text.toLowerCase()) == 0){
          arr.push(dataProvider[index]);
          valuesArr.push(dataProvider[index]);
        }
      }
      dataProvider = arr;
      if(!!arr.length){
        popover.open = true;
        positionPopup();
      }else{
        popover.open = false;
        dataProvider = provider;
      }
    }

    private function openPopup():void{
      popover.open = true;
			_button.addEventListener(MouseEvent.MOUSE_DOWN, handleControlMouseDown);
      popover.addEventListener(MouseEvent.MOUSE_DOWN, handleControlMouseDown);
			topMostEventDispatcher.addEventListener(MouseEvent.MOUSE_DOWN, handleTopMostEventDispatcherMouseDown);
      _button.addEventListener(KeyboardEvent.KEY_DOWN,changeValue);
    }
    private function closePopup():void{
      if(popover && popover.open){
  			popover.removeEventListener(MouseEvent.MOUSE_DOWN, handleControlMouseDown);
	  		_button.removeEventListener(MouseEvent.MOUSE_DOWN, handleControlMouseDown);
		  	topMostEventDispatcher.removeEventListener(MouseEvent.MOUSE_DOWN, handleTopMostEventDispatcherMouseDown);
        popover.open = false;
        dataProvider = provider;
        _button.removeEventListener(KeyboardEvent.KEY_DOWN,changeValue);
      }

    }
    private function positionPopoverBottom(componentBounds:Rectangle,maxHeight:Number):void{
      maxHeight -= 6;
      var pxStr:String;
      popover.setStyle("bottom","");
      pxStr = componentBounds.bottom + "px";
      popover.setStyle("top",pxStr);
      pxStr = maxHeight + "px";
      popover.setStyle("max-height",pxStr);
      if(popover.position == "top"){
        popover.position = "bottom";
      }
    }
    private function positionPopoverTop(bottom:Number,maxHeight:Number):void{
      maxHeight -= 6;
      var pxStr:String;
      pxStr = bottom + "px";
      popover.setStyle("top","");
      popover.setStyle("bottom",pxStr);
      pxStr = maxHeight + "px";
      popover.setStyle("max-height",pxStr);
      if(popover.position == "bottom"){
        popover.position = "top";
      }
    }
		protected function handleControlMouseDown(event:MouseEvent):void
		{			
			event.stopImmediatePropagation();
		}
		protected function handleTopMostEventDispatcherMouseDown(event:MouseEvent):void
		{
      closePopup();
		}
    public function get dataProvider():Object{
      return menu.dataProvider;
    }
    public function set dataProvider(value:Object):void{
      valuesArr = [];
      if(value is Array){
        convertArray(value);
      } else if(value is IArrayList){
        convertArray(value.source);
      }else{
        valuesArr = value;
      }
      menu.dataProvider = value;
    }

    public function get selectedIndex():int
    {
    	return menu.selectedIndex;
    }

    public function set selectedIndex(value:int):void
    {
    	menu.selectedIndex = value;
      setButtonText();
    }

    private function setButtonAsset(index:int,icon:Boolean):void{
      if(_button.getElementAt(0) is IAsset){
        _button.removeElement(_button.getElementAt(0));
      }
      if (icon)
      {
        var iconClone:Icon = new Icon(dataProvider[index].icon);
        _button.addElementAt(iconClone, 0);
      } else
      {
        var asset:ImageAsset = new ImageAsset();
        asset.style = "width:18px;margin-right:8px;";      
        asset.src = icon? dataProvider[index].icon: dataProvider[index].imageIcon;
        _button.addElementAt(asset,0);
      }
    }
    private function setButtonText():void{
      if(selectedIndex){
        if(selectedIndex < 0 || dataProvider[selectedIndex].isDivider){
          _button.text = "";
        }else{
          _button.text = dataProvider[selectedIndex].text;
          if(dataProvider[selectedIndex].imageIcon){
            setButtonAsset(selectedIndex,false);
          }else if(dataProvider[selectedIndex].icon){
            setButtonAsset(selectedIndex,true);
          }
        }
      }else if(!selectedItem ||selectedItem.isDivider){
        _button.text = "";
      }else{
        _button.text = selectedItem.text;
        var i:int = dataProvider.indexOf(selectedItem)
        if(dataProvider[i].imageIcon){
          setButtonAsset(i,false);
        }else if(dataProvider[i].icon){
          setButtonAsset(i,true);
        }
      }

    }

    public function get selectedItem():Object
    {
    	return menu.selectedItem;
    }

    public function set selectedItem(value:Object):void
    {
    	menu.selectedItem = value;
      setButtonText();
    }
    private function convertArray(value:Object):void{
      var len:int = value.length;
      for(var i:int = 0;i<len;i++){
        if(value[i] is IMenuItem){
            valuesArr.push(value[i]);
          continue;
        }
        var item:MenuItem = new MenuItem(getLabelFromData(this,value[i]));
        valuesArr.push(value[i]);
        if(value[i].isDivider){
          item.isDivider = value[i]["isDivider"];
        }
        if(value[i].disabled){
          item.disabled = value[i]["disabled"];
        }
        if(value[i].icon){
          item.icon = value[i]["icon"];
        }
        if(value[i].imageIcon){
          item.imageIcon = value[i]["imageIcon"];
        }
        if(value[i].selected || i == selectedIndex || value[i] == selectedItem){
          item.selected = value[i]["selected"];
          if(item.icon){
            setButtonAsset(i,true);
          }else if(item.imageIcon){
            setButtonAsset(i,false);
          }
        }
        value[i] = item;
      }
    }
    private var _placeholder:String;
    public function get placeholder():String
    {
    	return _placeholder;
    }

    public function set placeholder(value:String):void
    {
      _placeholder = value;
    	_button.placeholderText = value;
    }

    public function handleListChange():void{
      closePopup();
      setButtonText();
      dispatchEvent(new Event("change"));
    }
    
    private var _invalid:Boolean;

    public function get invalid():Boolean
    {
    	return _invalid;
    }

    public function set invalid(value:Boolean):void
    {
      if(value != _invalid){
        toggle("is-invalid",value);
        _button.invalid = value;
        if(value){
          var invalidIcon:Icon = new Icon(IconPrefix._18 + "Alert");
          invalidIcon.size = "S";
          _button.addElementAt(invalidIcon, _button.numElements - 1);
        }else{
          _button.removeElement(invalidIcon);
        }
      }
    	_invalid = value;
    }
    private var _quiet:Boolean;

    public function get quiet():Boolean
    {
    	return _quiet;
    }

    public function set quiet(value:Boolean):void
    {
      if(value != _quiet){
        toggle(valueToSelector("quiet"),value);
        _button.quiet = value;
        popover.quiet = value;
      }
    	_quiet = value;
    }

    private var _disabled:Boolean;

    public function get disabled():Boolean
    {
    	return _disabled;
    }

    public function set disabled(value:Boolean):void
    {
      if(value != !!_disabled){
        toggle("is-disabled",value);
        _button.disabled = value;
      }
    	_disabled = value;
    }
    private var _popupWidth:Number;

    public function get popupWidth():Number
    {
    	return _popupWidth;
    }

    public function set popupWidth(value:Number):void
    {
    	_popupWidth = value;
      popover.width = value;
    }
    private var _position:String;

    public function get position():String
    {
    	return _position;
    }

    private var _minMenuHeight:Number = 60;

    public function get minMenuHeight():Number
    {
    	return _minMenuHeight;
    }

    public function set minMenuHeight(value:Number):void
    {
    	_minMenuHeight = value;
    }

    [Inspectable(category="General", enumeration="bottom,top,right,left")]
    public function set position(value:String):void
    {
      switch(value){
        case "bottom":
        // break;
          case "top":
              // (element as HTMLElement).insertBefore((element as HTMLElement).removeChild(popover.element as HTMLElement),button.element as HTMLElement);
            // popover.style = {"bottom":"30px"};
            // break;
          case "right":
          case "left":
            break;
          default:
            throw new Error("invalid position: " + value);
      }
      if(value != !!_position){
        popover.position = value;
      }
    	_position = value;
    }
  }
}