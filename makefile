VPATH = src/





app: menu.js main.js



main.js: Article.elm ArticleId.elm Drag.elm elm-package.json Export.elm Interop.elm Linked.elm Main.elm Model.elm Msg.elm Point.elm SpecialEvents.elm Subs.elm Update.elm View.elm 
	elm-make --output main.js src/Main.elm

menu.js: Menu.elm
	elm-make --output menu.js src/Menu.elm
