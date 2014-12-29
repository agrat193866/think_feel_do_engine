;(function ( $ ) {
	$.fn.ngResponsiveTables = function(options) {
		var defaults = {
		smallPaddingCharNo: 5,
		mediumPaddingCharNo: 10,
		largePaddingCharNo: 15,
		shiftedIndex: 0,
		headerAdjust:false,
		headers:[""]
		},
		$selElement = this,
		ngResponsiveTables = {
			opt: '',
			dataContent: '',
			globalWidth: 0,
		init: function(){
			this.opt = $.extend( defaults, options );
			ngResponsiveTables.targetTable();
		},
		targetTable: function(){
			var that = this;
			$selElement.find('tr').each(function(){
				$(this).find('td').each(function(i, v){
					if(!$(this).hasClass('ignore_cell')){
						that.checkForTableHead($(this), i);
						if(i == that.opt.shiftedIndex) {$(this).addClass("responsive-header");}
						$(this).addClass('tdno' + i);
					}
				});
			});
		},
		checkForTableHead: function(element, index){
			if(index >= this.opt.shiftedIndex){
				actualIndex = index - this.opt.shiftedIndex;
				if( $selElement.find('th').length > actualIndex){
					if(this.opt.headerAdjust){
						this.dataContent = this.opt.headers[actualIndex];
					}
					else{
						this.dataContent = $selElement.find('th')[actualIndex].textContent;
					}
				}else{
					this.dataContent = "";
				}
				element.attr('data-content', this.dataContent);
			}else{
				element.attr('data-content', "");
			}
			if( this.opt.smallPaddingCharNo > $.trim(this.dataContent).length ){
				element.addClass('small-padding');
			}else if( this.opt.mediumPaddingCharNo > $.trim(this.dataContent).length ){
				element.addClass('medium-padding');
			}else{
				element.addClass('large-padding');
			}
			
		}
	};

	$(function(){
		ngResponsiveTables.init();
	});
		return this;
	};

}( jQuery ));