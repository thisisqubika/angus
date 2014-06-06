/*
Sticky Elements Shortcut for jQuery Waypoints - v2.0.3
Copyright (c) 2011-2013 Caleb Troughton
Dual licensed under the MIT license and GPL license.
https://github.com/imakewebthings/jquery-waypoints/blob/master/licenses.txt
*/
!function(){!function(t,n){return"function"==typeof define&&define.amd?define(["jquery","waypoints"],n):n(t.jQuery)}(this,function(t){var n,s;return n={wrapper:'<div class="sticky-wrapper" />',stuckClass:"stuck"},s=function(t,n){return t.wrap(n.wrapper),t.parent()},t.waypoints("extendFn","sticky",function(e){var i,r,a;return r=t.extend({},t.fn.waypoint.defaults,n,e),i=s(this,r),a=r.handler,r.handler=function(n){var s,e;return s=t(this).children(":first"),e="down"===n||"right"===n,s.toggleClass(r.stuckClass,e),i.height(e?s.outerHeight():""),null!=a?a.call(this,n):void 0},i.waypoint(r),this.data("stuckClass",r.stuckClass)}),t.waypoints("extendFn","unsticky",function(){return this.parent().waypoint("destroy"),this.unwrap(),this.removeClass(this.data("stuckClass"))})})}.call(this);