default: boxicons css goatcounter

boxicons:
	curl -sL --output-dir assets/css/ \
		-O https://unpkg.com/boxicons/css/boxicons.css
	curl -sL --output-dir static/fonts/ \
		-O https://unpkg.com/boxicons/fonts/boxicons.woff \
		-O https://unpkg.com/boxicons/fonts/boxicons.woff2 \
		-O https://unpkg.com/boxicons/fonts/boxicons.ttf \
		-O https://unpkg.com/boxicons/fonts/boxicons.svg \
		-O https://unpkg.com/boxicons/fonts/boxicons.eot
.PHONY: boxicons

css:
	curl -sL --output-dir assets/css/ \
		-O https://necolas.github.io/normalize.css/latest/normalize.css \
		-O https://raw.githubusercontent.com/acahir/Barebones/master/css/barebones.css \
		-O https://raw.githubusercontent.com/fncnt/vncnt-hugo/master/static/css/vncnt.css

	@# Fix vncnt.css expecting barebones.css and getting barebones.min.css
	sed -i '.bak' '/barebones.css/d' assets/css/vncnt.css && rm assets/css/vncnt.css.bak
.PHONY: css

goatcounter:
	curl -sL --output-dir assets/js/ \
		-O https://gc.zgo.at/count.js
.PHONY: goatcounter
