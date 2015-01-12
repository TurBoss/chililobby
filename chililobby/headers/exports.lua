--chili export
CHILI_LOBBY_IMG_DIR = CHILILOBBY_DIR .. "images/"

if WG and WG.Chili then
    -- setup Chili
    Chili = WG.Chili
    Checkbox = Chili.Checkbox
    Control = Chili.Control
    ComboBox = Chili.ComboBox
    Button = Chili.Button
    Label = Chili.Label
    Line = Chili.Line
    EditBox = Chili.EditBox
    Window = Chili.Window
    ScrollPanel = Chili.ScrollPanel
    LayoutPanel = Chili.LayoutPanel
    StackPanel = Chili.StackPanel
    Grid = Chili.Grid
    TextBox = Chili.TextBox
    Image = Chili.Image
    TreeView = Chili.TreeView
    Trackbar = Chili.Trackbar
    screen0 = Chili.Screen0
end
--lobby export
if WG and WG.LibLobby then
    LibLobby = WG.LibLobby
    lobby = LibLobby.lobby
end

i18n = VFS.Include("libs/i18n/i18n/init.lua", nil, VFS.DEF_MODE)
i18n.set('en.connect-to-spring-server', 'Connect to the Spring lobby server')
i18n.set('en.username', 'Username')
i18n.set('en.password', 'Password')
i18n.set('en.login-noun', 'Login')
i18n.set('en.login-verb', 'Login')

i18n.set('sr.connect-to-spring-server', 'Prijavljivanje na Spring lobi server')
i18n.set('sr.username', 'Nalog')
i18n.set('sr.password', 'Lozinka')
i18n.set('sr.login-noun', 'Prijavljivanje')
i18n.set('sr.login-verb', 'Prijavi me')

--i18n.setLocale('sr')