$(document).ready(function(){$(".charts a").fancybox(),$(".navigation").localScroll(),$("section").waypoint(function(t){var a=$(this);thisId=$(this).attr("id"),$("ul.nav li a").each(function(){var i=$(this).attr("class");i==thisId&&($("ul li a").removeClass("active"),"up"===t&&(a=$(this).prev()),a.length||(a=$(this)),$(this).addClass("active"))})},{offset:20}),$("a[href*=#]:not([href=#])").click(function(){if(location.pathname.replace(/^\//,"")==this.pathname.replace(/^\//,"")||location.hostname==this.hostname){var t=$(this.hash);if(t=t.length?t:$("[name="+this.hash.slice(1)+"]"),t.length)return $("html,body").animate({scrollTop:t.offset().top},0),!1}}),$("section#why_angus").waypoint(function(){$(".navigation ul.nav").toggleClass("fixed")},{offset:20}),$("#main").waypoint(function(){$(".navigation").toggleClass("mobile-fixed")},{offset:0})});