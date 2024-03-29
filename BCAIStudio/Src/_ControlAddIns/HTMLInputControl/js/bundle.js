! function () {
    "use strict";
    var p = "beforeend",
        y = "__toolbar-item",
        d = function (t, e, n, r) {
            var a = document.createElement("select");
            a.dataset.commandId = t, a.className = y, a.title = e, a.addEventListener("change", function (e) {
                return r(t, e.target.options[e.target.selectedIndex].value)
            });
            var l, i, o, d, c = !0,
                s = !1,
                u = void 0;
            try {
                for (var f, m = n[Symbol.iterator](); !(c = (f = m.next()).done); c = !0) {
                    var v = f.value;
                    a.insertAdjacentElement(p, (l = v.value, i = v.text, o = v.selected, d = void 0, (d = document.createElement("option")).innerText = i, l && d.setAttribute("value", l), o && d.setAttribute("selected", o), d))
                }
            } catch (e) {
                s = !0, u = e
            } finally {
                try {
                    c || null == m.return || m.return()
                } finally {
                    if (s) throw u
                }
            }
            return a
        },
        c = function (e, t, n, r) {
            var a = document.createElement("button");
            return a.dataset.commandId = e, a.className = y, a.title = t, a.type = "button", a.insertAdjacentElement(p, n), a.addEventListener("click", function () {
                return r(e)
            }), a
        },
        s = function (e) {
            var t = document.createElement("i");
            return t.className = e, t
        },
        u = "no",
        f = function () {
            var e = document.createElement("span");
            return e.className = "__toolbar-separator", e
        },
        r = function (e, t) {
            var n, r, a, l, i, o = document.createElement("div");
            return o.className = "__toolbar", e.formatblock !== u && o.insertAdjacentElement(p, d("formatblock", "Styles", [{
                value: "h1",
                text: "Title 1"
            }, {
                value: "h2",
                text: "Title 2"
            }, {
                value: "h3",
                text: "Title 3"
            }, {
                value: "h4",
                text: "Title 4"
            }, {
                value: "h5",
                text: "Title 5"
            }, {
                value: "h6",
                text: "Title 6"
            }, {
                value: "p",
                text: "Paragraph",
                selected: !0
            }, {
                value: "pre",
                text: "Preformatted"
            }], t)), e.fontname !== u && o.insertAdjacentElement(p, d("fontname", "Font", [{
                value: "serif",
                text: "Serif",
                selected: !0
            }, {
                value: "sans-serif",
                text: "Sans Serif"
            }, {
                value: "monospace",
                text: "Monospace"
            }, {
                value: "cursive",
                text: "Cursive"
            }, {
                value: "fantasy",
                text: "Fantasy"
            }], t)), e.bold !== u && o.insertAdjacentElement(p, c("bold", "Bold", s("fas fa-bold"), t)), e.italic !== u && o.insertAdjacentElement(p, c("italic", "Italic", s("fas fa-italic"), t)), e.underline !== u && o.insertAdjacentElement(p, c("underline", "Underline", s("fas fa-underline"), t)), e.forecolor !== u && o.insertAdjacentElement(p, (n = "forecolor", r = "Text color", a = "color", l = t, (i = document.createElement("input")).dataset.commandId = n, i.className = y, i.title = r, i.type = a, i.addEventListener("change", function (e) {
                return l(n, e.target.value)
            }), i)), o.insertAdjacentElement(p, f()), e.justifyleft !== u && o.insertAdjacentElement(p, c("justifyleft", "Left align", s("fas fa-align-left"), t)), e.justifycenter !== u && o.insertAdjacentElement(p, c("justifycenter", "Center align", s("fas fa-align-center"), t)), e.justifyright !== u && o.insertAdjacentElement(p, c("justifyright", "Right align", s("fas fa-align-right"), t)), o.insertAdjacentElement(p, f()), e.insertorderedlist !== u && o.insertAdjacentElement(p, c("insertorderedlist", "Numbered list", s("fas fa-list-ol"), t)), e.insertunorderedlist !== u && o.insertAdjacentElement(p, c("insertunorderedlist", "Bulleted list", s("fas fa-list-ul"), t)), e.outdent !== u && o.insertAdjacentElement(p, c("outdent", "Decrease indent", s("fas fa-indent fa-flip-horizontal"), t)), e.indent !== u && o.insertAdjacentElement(p, c("indent", "Increase indent", s("fas fa-indent"), t)), o.insertAdjacentElement(p, f()), e.removeFormat !== u && o.insertAdjacentElement(p, c("removeFormat", "Clear formatting", s("fas fa-eraser"), t)), o
        };
    ! function (e, t) {
        void 0 === t && (t = {});
        var n = t.insertAt;
        if (e && "undefined" != typeof document) {
            var r = document.head || document.getElementsByTagName("head")[0],
                a = document.createElement("style");
            a.type = "text/css", "top" === n && r.firstChild ? r.insertBefore(a, r.firstChild) : r.appendChild(a), a.styleSheet ? a.styleSheet.cssText = e : a.appendChild(document.createTextNode(e))
        }
    }(".__editor {\r\n  background: #ffffff;\r\n  height: 135px;\r\n  border: solid 1px #e0e0e0;\r\n  color: #000000;\r\n  margin-top: 10px;\r\n  overflow-y: auto;\r\n  padding: 10px;\r\n}\r\n\r\n.__editor:focus {\r\n  outline: none;\r\n}\r\n\r\n.__toolbar {\r\n  display: flex;\r\n  flex-wrap: wrap;\r\n  padding: 5px;\r\n}\r\n\r\n.__toolbar-item {\r\n  background: #ffffff;\r\n  border: 0;\r\n  border-radius: 3px;\r\n  cursor: pointer;\r\n  margin-right: 7px;\r\n  min-width: 30px;\r\n  padding: 5px;\r\n}\r\n\r\n.__toolbar-item:hover,\r\n.__toolbar-item.active {\r\n  background: #f0f0f0;\r\n}{\r\n  border-left: solid 1px #e0e0e0;\r\n  margin-right: 7px;\r\n}{\r\n  display: none;\r\n}\r\n"), document.querySelectorAll("[data-tiny-editor]").forEach(function (n) {
        n.setAttribute("contentEditable", !0), n.className = "__editor";
        var e = function (e, t) {
            document.execCommand(e, !1, t), n.focus()
        };
        e("defaultParagraphSeparator", "p");
        var C = r(n.dataset, e);
        n.insertAdjacentElement("beforebegin", C);
        var t = function () {
            var e = C.querySelectorAll("select[data-command-id]"),
                t = !0,
                n = !1,
                r = void 0;
            try {
                for (var a, l = function () {
                    var e = a.value,
                        t = document.queryCommandValue(e.dataset.commandId),
                        n = Array.from(e.options).find(function (e) {
                            return e.value === t
                        });
                    e.selectedIndex = n ? n.index : -1
                }, i = e[Symbol.iterator](); !(t = (a = i.next()).done); t = !0) l()
            } catch (e) {
                n = !0, r = e
            } finally {
                try {
                    t || null == i.return || i.return()
                } finally {
                    if (n) throw r
                }
            }
            var o = C.querySelectorAll("button[data-command-id]"),
                d = !0,
                c = !1,
                s = void 0;
            try {
                for (var u, f = o[Symbol.iterator](); !(d = (u = f.next()).done); d = !0) {
                    var m = u.value,
                        v = document.queryCommandState(m.dataset.commandId);
                    m.classList.toggle("active", v)
                }
            } catch (e) {
                c = !0, s = e
            } finally {
                try {
                    d || null == f.return || f.return()
                } finally {
                    if (c) throw s
                }
            }
            var p, y, x, E, b = C.querySelectorAll("input[data-command-id]"),
                h = !0,
                g = !1,
                A = void 0;
            try {
                for (var j, _ = b[Symbol.iterator](); !(h = (j = _.next()).done); h = !0) {
                    var S = j.value,
                        I = document.queryCommandValue(S.dataset.commandId);
                    S.value = (E = void 0, p = /(.*?)rgb\((\d+), (\d+), (\d+)\)/.exec(I), y = parseInt(p[2]), x = parseInt(p[3]), E = parseInt(p[4]) | x << 8 | y << 16, p[1] + "#" + E.toString(16).padStart(6, "0"))
                }
            } catch (e) {
                g = !0, A = e
            } finally {
                try {
                    h || null == _.return || _.return()
                } finally {
                    if (g) throw A
                }
            }
        };
        n.addEventListener("keydown", t), n.addEventListener("keyup", t), n.addEventListener("click", t), C.addEventListener("click", t)
    })
}();