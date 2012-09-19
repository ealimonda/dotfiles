#! /bin/sh
#*******************************************************************************************************************
#* Config files                                                                                                    *
#*******************************************************************************************************************
#* File:             imggallery.sh                                                                                 *
#* Copyright:        (c) 2011-2012 alimonda.com; Emanuele Alimonda                                                 *
#*                   Public Domain                                                                                 *
#*******************************************************************************************************************

MODE=normal
if [ "$1" == "--fancy" ]; then
	MODE=fancy
	shift
fi

if [ -z "$1" ]; then
	galleryname="My Images"
else
	galleryname="$1"
fi

echo "<!DOCTYPE HTML>" > index.html
echo "<html>" >> index.html
echo "<head>" >> index.html
echo '	<meta http-equiv="Content-Type" content="text/html;charset=utf-8" >' >> index.html
echo "	<title>${galleryname}</title>" >> index.html
if [ "$MODE" == "fancy" ]; then
	cat >> index.html << EOF
	<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7/jquery.min.js"></script>
	<!--<script type="text/javascript" src="fancybox/jquery.mousewheel-3.0.6.pack.js"></script>-->
	<script type="text/javascript" src="fancybox/jquery.fancybox.js"></script>
	<link rel="stylesheet" type="text/css" href="fancybox/jquery.fancybox.css" media="screen" />
	<link rel="stylesheet" type="text/css" href="fancybox/jquery.fancybox-buttons.css?v=2.0.4" />
	<script type="text/javascript" src="fancybox/jquery.fancybox-buttons.js?v=2.0.4"></script>
	<link rel="stylesheet" type="text/css" href="fancybox/jquery.fancybox-thumbs.css?v=2.0.4" />
	<script type="text/javascript" src="fancybox/jquery.fancybox-thumbs.js?v=2.0.4"></script>
	<script type="text/javascript">
	\$(document).ready(function() {
		\$(".fancybox").each(function() {
			\$(this).fancybox({
				'afterClose' : function() {
					location.hash = '';
				},
				'beforeShow' : function(opts) {
					location.hash = this.element.id;
				},
				'helpers'  : {
					'title'   : { type : 'outside' },
					'thumbs'  : { width  : 50, height : 50 },
					'buttons' : {},
				},
			});
		});
		if(location.hash != "" && \$(location.hash) ) {
			\$(location.hash.replace('.','\\\\.')).click();
		}
	});
	</script>
EOF
fi
echo "</head>" >> index.html
echo "<body>" >> index.html
echo "<h1>${galleryname}</h1>" >> index.html

mkdir thumbs

for img in *.[jJ][pP][gG]; do
	echo $img
	convert -scale 120 $img thumbs/thumb-$img
#     mogrify -scale 640 $img
	if [ "$MODE" == "fancy" ]; then
		echo "<a class=\"fancybox\" id=\"$img\" href=\"$img\" title=\"$img\" rel=\"gallery\"><img src=\"thumbs/thumb-$img\" alt=\"$img\"/></a>" >> index.html
	else
		echo "<a href=\"$img\"><img src=\"thumbs/thumb-$img\" alt=\"$img\"/></a>" >> index.html
	fi
done
echo "</body>" >> index.html
echo "</html>" >> index.html
