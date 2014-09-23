var holdscroll;
var safetylock;
//In the rare case that both left and right mb are pressed at once it gets stuck scrolling forever; safetylock
//helps avoid that.
var SCROLLING_DIV = 'div#tool-layout.container  div.row > div.tool-content, div#main-layout.container div#inbox.active, div#main-layout.container div#sent.active';
var INDICATOR_DIV = 'div#tool-layout.container  div.row > div.tool-nav, div#main-layout div.tab-content';


$(document).ready(function(){ 
	$(document).on("page:change",reregister_handle);
	$(document).on("page:load", check_scrollable_element); 
	check_scrollable_element(); 
}); 

function check_scrollable_element() 
{ 
	var elem = $(SCROLLING_DIV);
	if(elem.length > 0) 
	{ 
		elem.scroll(check_clear_indicator);
		elem.off("mousedown DOMMouseScroll mousewheel keyup", user_scroll_clear);
		elem.on("mousedown DOMMouseScroll mousewheel keyup", user_scroll_clear);
		if(elem[0].scrollHeight > elem[0].offsetHeight)
		{
			$(INDICATOR_DIV).addClass("scroll_indicator");
			toggle_scrollable(true);
			window.setTimeout(check_scrollable_element,1000);
		}
		else
		{
			safetylock = true;
			toggle_scrollable(false);
			window.setTimeout(check_scrollable_element,1000);
		}
		check_clear_indicator({target:elem[0]});
	} 
} 

function reregister_handle()
{
	$("div#main-layout ul#messages-tab li a").on("click",function (e) {
  		$(this).tab('show').then(check_scrollable_element());
	}); 
}

function toggle_scrollable(toggleon)
{
	if(toggleon) $("div#scroll_btn").on("mousedown touchstart touchenter",start_scroll).on("mouseup mouseleave touchcancel touchend touchleave",end_scroll);
	else $("div#scroll_btn").off("mousedown touchstart touchenter",start_scroll);
}

function start_scroll(e)
{
	safetylock = false;
	cause_scroll();
	holdscroll = setTimeout(cause_scroll,100);
}

function cause_scroll()
{
	var elem = $(SCROLLING_DIV);
	if(elem.length > 0) $(elem[0]).scrollTop($(elem[0]).scrollTop() + 5); 
	if(!safetylock)	holdscroll = setTimeout(cause_scroll,100);
}

function end_scroll(e)
{
	safetylock = true;
	clearTimeout(holdscroll);
}

function user_scroll_clear(e){
    	safetylock = true;
    	clearTimeout(holdscroll);
}

function check_clear_indicator(e) 
{ 
	var indicator = $(INDICATOR_DIV);
	if(e.target.scrollHeight == $(e.target).scrollTop() + e.target.offsetHeight)
	{
		indicator.removeClass("scroll_indicator");
		toggle_scrollable(false);
		safetylock = true;
		clearTimeout(holdscroll);
	}
	else if (!indicator.hasClass("scroll_indicator"))
	{
		indicator.addClass("scroll_indicator");
		toggle_scrollable(true);
	}
}
