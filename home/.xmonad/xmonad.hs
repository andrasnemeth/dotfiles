{-# LANGUAGE UnicodeSyntax #-}
-- {{{ Imports
-- stuff
import XMonad
import qualified XMonad.StackSet as W
import qualified Data.Map as M
import System.Exit
import Graphics.X11.Xlib
--import System.IO.UTF8 (hPutStrLn)
--import System.IO (hPutStrLn)
import Data.ByteString.Char8 (hPutStrLn, pack)
--import System.IO (Handle, hPutStrLn)
--import System.IO (Handle)
--import System.IO.UTF8
import qualified GHC.IO.Handle.Types as H

-- utils
import XMonad.Util.Run (spawnPipe)
import XMonad.Actions.NoBorders
import XMonad.Actions.CycleWS
import XMonad.Actions.Promote
import XMonad.Actions.DynamicWorkspaces as DW
import XMonad.Actions.CopyWindow (copy)
import XMonad.Actions.WindowBringer

-- hooks
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.XPropManage
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.DebugEvents
import XMonad.Hooks.DebugKeyEvents
import XMonad.Hooks.DebugStack
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.Place
--import XMonad.Hooks.FadeInactive
-- Dialog and menu hooks
import Graphics.X11.Xlib.Extras
import Foreign.C.Types (CLong)

-- layouts
import XMonad.Layout.NoBorders
import XMonad.Layout.ResizableTile
import XMonad.Layout.Gaps
import XMonad.Layout.Named
import XMonad.Layout.PerWorkspace
import XMonad.Layout.IM
import XMonad.Layout.Grid
import XMonad.Layout.Accordion
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances
import XMonad.Layout.Spacing
import XMonad.Layout.WindowNavigation
import XMonad.Layout.Circle
import XMonad.Layout.Cross
import XMonad.Layout.Mosaic
import XMonad.Layout.MagicFocus -- replaced by Promote
import XMonad.Layout.Tabbed (tabbedBottomAlways, defaultTheme, Theme(..), shrinkText)
import XMonad.Layout.LayoutHints
import qualified XMonad.Layout.Fullscreen as FS
import XMonad.Layout.BoringWindows
--import XMonad.Layout.Spacing -- add "spacing 2 $" to the beginning of customLayout
import Data.Ratio((%))
--import Data.ByteString.UTF8 (fromString, toString, decode)
--import Codec.Binary.UTF8.String (encodeString, decodeString, utf8Encode)
--import Data.Encoding
--import Data.String.CP1251
--import Data.String.UTF8 (toRep, fromRep)

import XMonad.Prompt
import XMonad.Prompt.XMonad
import XMonad.Prompt.Shell
import XMonad.Prompt.Workspace
import XMonad.Prompt.AppendFile
--import XMonad.Prompt.Input

import XMonad.Util.EZConfig
import XMonad.Util.Scratchpad
-- }}}
-------------------------------------------------------------------------------

-- {{{ Workspaces

-- for the sake of searchability among opened winows, i suppress
-- dzen's workspace switching capabilities
myWorkspaces' :: [String]
myWorkspaces' = clickable . map dzenEscape $
               --[ "I", "II", "III", "IV", "V", "VI"]
               --["1:α","2:β","3:γ","4:δ","5:ε","6:ζ"]
               ["term", "dev", "web", "irssi"]
               --["web", "mail", "term", "im", "music", "irssi", "\x2192", "λ",  "σ"]
    where clickable l = [ x ++ ws ++ "^ca()^ca()^ca()" |
                        (i,ws) <- zip "123456789" l,
                        let n = i
                            x =    "^ca(4,xdotool key Super+Control+Left)"
                                ++ "^ca(5,xdotool key Super+Control+Right)"
                                ++ "^ca(1,xdotool key Super+F" ++ show n ++ ")"]

myWorkspaces :: [String]
myWorkspaces = [" λ "," α "," β "," γ "," δ "," ε "," ζ "]
--myWorkspaces = ["term", "dev", "web", "irssi"]

-- }}}

-- {{{ Mouse
myMouseBindings :: XConfig t -> M.Map (KeyMask, Button) (Window -> X ())
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList
    [ ((modm, button1), \w -> focus w >> mouseMoveWindow w
                                      >> windows W.shiftMaster)
    , ((modm, button2), \w -> focus w >> windows W.shiftMaster)
    , ((modm, button3), \w -> focus w >> mouseResizeWindow w
                                      >> windows W.shiftMaster)
    ]
-- }}}

-- {{{ Colors
type Hex = String
type ColorCode = (Hex,Hex)
type ColorMap = M.Map Colors ColorCode

data Colors = Black | Red | Green | Yellow | Blue | Magenta | Cyan | White | BG | MyGreen
    deriving (Ord,Show,Eq)

colLook :: Colors -> Int -> Hex
colLook color n =
    case M.lookup color colors of
        Nothing -> "#000000"
        Just (c1,c2) -> if n == 0
                        then c1
                        else c2

colors :: ColorMap
colors = M.fromList
    [ (Black   , ("#393939",
                  "#121212"))
    , (Red     , ("#e60926",
                  "#df2821"))
    , (Green   , ("#219e74",
                  "#219579"))
    , (Yellow  , ("#218c7e",
                  "#218383"))
    , (Blue    , ("#217a88",
                  "#21728d"))
    , (Magenta , ("#216992",
                  "#216097"))
    , (Cyan    , ("#21579c",
                  "#214ea1"))
    , (White   , ("#D6D6D6",
                  "#A3A3A3"))
    , (BG      , ("#000000",
                  "#444444"))
    , (MyGreen , ("#99a9cf",
                  "#000000"))
    ]

-- }}}

myFontName :: String
myFontName = "-*-Terminus-regular-r-normal-*-12-*-*-*-*-*-*-*"

-- {{{ Main
main :: IO ()
main = do
--       spawnPipe "xmobar ~/.xmobarrc1"
--       h <- spawnPipe "xmobar ~/.xmobarrc"
       h <- spawnPipe callDzen1
       spawn callDzen2
--       spawn conkydesktop
--       spawn "xmobar ~/.xmobarrc1"
       xmonad $ withUrgencyHook dzenUrgencyHook $ ewmh defaultConfig
              { --workspaces = ["1:A", "2:B ", "3:C ", "4:D ","5:E ", "6:F ", "7:G"]
                --workspaces = ["\7b1","1:α","2:β","3:γ","4:δ","5:ε","6:ζ"]
                workspaces = myWorkspaces
              , modMask = mod4Mask -- mod1Mask (left-alt), mod3Mask(right alt) mod4Mask is super
              , borderWidth = 1
              , normalBorderColor = "#5a5a5a"
              , focusedBorderColor = colLook Cyan 1 -- #daff30
              , terminal = "urxvt"-- -title urxvt"
              , keys = keys'
              , logHook = myLogHook h --logHook' h
              , layoutHook = myLayout --layoutHook'
              , manageHook = manageHook' --manageHook'
              , focusFollowsMouse = False
              , mouseBindings = myMouseBindings
              , handleEventHook = handleEventHook defaultConfig <+> fullscreenEventHook
              }
    where callDzen1 = "dzen2 -ta l -fn '"
                      ++ dzenFont
                      ++ "' -bg '#000000' -w 600 -h 18 -e 'button3='"
          callDzen2 = "conky | dzen2 -x 600 -ta r -fn '"
                      ++ dzenFont
                      ++ "' -bg '#000000' -h 18 -e 'onnewinput=;button3='"
          conkydesktop = "conky -c ~/.conkydesktop"
          dzenFont  = "Terminus-8"--"Inconsolata-8"
          -- | Layouts --¬
          myLayout = --mkToggle (NOBORDERS ?? FULL ?? EOT) $
              boringWindows $
              FS.fullscreenFull $
              avoidStruts $
              --smartBorders $
              --magicFocus $
              webLayout
              standardLayout
              where
                  standardLayout = tiled
                                   ||| mirrorTiled
                                   ||| focused
                                   -- ||| Accordion
                                   -- ||| im
                                   -- ||| Circle
                                   -- ||| simpleCross
                                   -- ||| mosaic 2 [3,2]
                                   ||| myTab
                  webLayout      = onWorkspace (myWorkspaces !! 1) $ fullTiled
                                   ||| tiled
                                   ||| mirrorTiled
                  fullTiled      = Tall nmaster delta (1/3)
                  mirrorTiled    = Mirror $ Tall nmaster delta ratio
                  focused        = gaps [(L,185), (R,185),(U,15),(D,15)]
                                   $ noBorders (FS.fullscreenFull Full)
                  tiled          = Tall nmaster delta ratio
                  im             = named "InstantMessenger" $ withIM (12/50) (Role "buddy_list") Grid
                  myTab          = tabbedBottomAlways shrinkText myTabConfig
                  -- The default number of windows in the master pane
                  nmaster = 1
                  -- Percent of screen to increment by when resizing panes
                  delta   = 5/100
                  -- Default proportion of screen occupied by master pane
                  ratio   = 1/2

-- }}}
-------------------------------------------------------------------------------
-- {{{ Log Hooks
-- logHook' :: Handle ->  X ()
-- logHook' h = dynamicLogWithPP $ customPP h -- { ppOutput = Data.ByteString.Char8.hPutStrLn h }

-- customPP :: Handle -> PP
-- customPP h = defaultPP { ppCurrent = xmobarColor "#daff30" "#000000" . wrap "&" ""
--                      , ppTitle =  shorten 80
--                      , ppSep =  "<fc=#daff30> | </fc>"
--                      , ppHiddenNoWindows = xmobarColor "#777777" ""
--                      , ppUrgent = xmobarColor "#AFAFAF" "#333333" . wrap "&" ""
--                      , ppOutput = System.IO.UTF8.hPutStrLn h
--                      }

myLogHook ::  H.Handle -> X ()
myLogHook h = dynamicLogWithPP $ defaultPP
    {
        ppCurrent           =   dzenColor (colLook White   0)
                                          (colLook Black   0) . pad
      , ppVisible           =   dzenColor (colLook Black   0)
                                          (colLook White   0) . pad
      , ppHidden            =   dzenColor (colLook MyGreen 0)
                                          (colLook BG      0) . pad
      , ppHiddenNoWindows   =   dzenColor (colLook White   1)
                                          (colLook BG      0) . pad
      , ppUrgent            =   dzenColor (colLook Red     0)
                                          (colLook BG      0) . pad
      , ppWsSep             =   ""
      , ppSep               =   " | "
      , ppLayout            =   dzenColor (colLook MyGreen 0) "#000000" .
            (\x -> case x of
                "Spacing 5 Tall"         -> clickInLayout ++ icon1
                "Tall"                   -> clickInLayout ++ icon2
                "Mirror Tall"            -> clickInLayout ++ icon3
                "Full"                   -> clickInLayout ++ icon4
                "Tabbed Bottom Simplest" -> clickInLayout ++ icon5
                _                        -> x
            )
      , ppTitle             =   (" " ++) . dzenColor "white" "#000000" . dzenEscape
      , ppOutput            =   hPutStrLn h . pack --System.IO.hPutStrLn h --hPutStrLn h
    }
    where icon1 = "^i(/home/nrw/.xmonad/dzen/icons/stlarch/tile.xbm)^ca()"
          icon2 = "^i(/home/nrw/.xmonad/dzen/icons/stlarch/monocle.xbm)^ca()"
          icon3 = "^i(/home/nrw/.xmonad/dzen/icons/stlarch/bstack.xbm)^ca()"
          icon4 = "^i(/home/nrw/.xmonad/dzen/icons/stlarch/monocle2.xbm)^ca()"
          icon5 = "^i(/home/nrw/.xmonad/dzen/icons/stlarch/tabbed.xbm)^ca()"

clickInLayout :: String
clickInLayout = "^ca(1,xdotool key super+space)"

-- }}}
-------------------------------------------------------------------------------
-- {{{ Layout hooks
layoutHook' = customLayout
customLayout = gaps [(D,16)] $ avoidStruts $ onWorkspace "3:C" im $ smartBorders tiled ||| smartBorders (Mirror tiled) ||| im ||| noBorders Full ||| Accordion
  where
    tiled = named "Tiled" $ ResizableTall 1 (2/100) (1/2) []
    im = named "InstantMessenger" $ withIM (12/50) (Role "buddy_list") Grid
-- }}}
-------------------------------------------------------------------------------
-- {{{ Dialog and menu hooks
getProp :: Atom -> Window -> X (Maybe [CLong])
getProp a w = withDisplay $ \dpy -> io $ getWindowProperty32 dpy a w

checkAtom name value = ask >>= \w -> liftX $ do
                a <- getAtom name
                val <- getAtom value
                mbr <- getProp a w
                case mbr of
                  Just [r] -> return $ elem (fromIntegral r) [val]
                  _ -> return False

checkDialog = checkAtom "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_DIALOG"
checkMenu = checkAtom "_NET_WM_WINDOW_TYPE" "_NET_WM_WINDOW_TYPE_MENU"

manageMenus = checkMenu --> doFloat
manageDialogs = checkDialog --> doFloat
-- }}}
-------------------------------------------------------------------------------
-- {{{ Manage Hooks
myManageHook :: ManageHook
myManageHook = manageDocks <+> (composeAll . concat $
    [ [ className       =? c                 --> doFloat | c <- myFloats ]
    , [ title           =? t                 --> doFloat | t <- myOtherFloats ]
    , [ resource        =? r                 --> doIgnore | r <- myIgnores ]
--    , [ (className =? "URxvt" <&&> title =? "urxvt") --> doF (W.shift "1:A")]
    -- , [ className       =? "Gran Paradiso"         --> doF (W.shift "2:B") ]
    -- , [ className       =? "Chromium"         --> doF (W.shift "2:B") ]
    -- , [ className       =? "Gimp"            --> doF (W.shift "6:F") ]
    -- , [ className       =? "Emacs"            --> doF (W.shift "3:C") ]
    -- , [ className       =? "OpenOffice.org 3.0" --> doF (W.shift "6:F") ]
    -- , [ className       =? "Pidgin"          --> doF (W.shift "3:C") ]
    , [ scratchpadManageHook (W.RationalRect 0.125 0.25 0.75 0.5) ]
    ])
    where
        myIgnores       = ["stalonetray", "Conky", "conky"]
        myFloats        = []
        myOtherFloats   = ["alsamixer", "&#1053;&#1072;&#1089;&#1090;&#1088;&#1086;&#1081;&#1082;&#1080; Chromium", "&#1047;&#1072;&#1075;&#1088;&#1091;&#1079;&#1082;&#1080;", "&#1044;&#1086;&#1087;&#1086;&#1083;&#1085;&#1077;&#1085;&#1080;&#1103;", "Clear Private Data", "urxvt-float", "Eclipse SDK", "Eclipse", "Contact List", "Variety Preferences", "Variety Images", "#das"]

myManageHook' :: ManageHook
myManageHook' = composeAll . concat $
    [ [ className =? c  --> doFloat | c <- myFloats]
    , [ title =? t      --> doFloat | t <- myOtherFloats]
    , [ resource =? r   --> doIgnore | r <- myIgnores]
    ]
    where
      myIgnores = ["conky"]
      myFloats = []
      myOtherFloats = ["urxvt-float"]

manageHook' :: ManageHook
manageHook' =  placeHook (fixed (0.5,0.5)) <+> manageMenus <+> manageDialogs <+> FS.fullscreenManageHook <+> myManageHook
-- }}}
-------------------------------------------------------------------------------
-- {{{ X Prompt config
myXPConfig :: XPConfig
myXPConfig = defaultXPConfig
  { font                = myFontName
  , bgColor             = "#131313"
  , fgColor             = "#888888"
  , bgHLight            = "#2A2A2A"
  , fgHLight            = "#3579A8"
  , promptBorderWidth   = 0
  , position            = Top
  , height              = 16
  , historySize         = 100
  , historyFilter       = deleteConsecutive
  }
-- }}}
-------------------------------------------------------------------------------
-- {{{ Tabbed layout config
myTabConfig :: Theme
myTabConfig = defaultTheme
    { activeColor         = "#2A2A2A"
    , inactiveColor       = "#131313"
    , activeBorderColor   = "#2A2A2A"
    , inactiveBorderColor = "#131313"
    , activeTextColor     = "#3579A8"
    , inactiveTextColor   = "#888888"
    , urgentColor         = colLook BG 0
    , urgentBorderColor   = colLook BG 0
    , urgentTextColor     = colLook Red 0
    , decoHeight          = 16
    --, tabSize             = 14
    , fontName            = myFontName
    }
-- }}}
-------------------------------------------------------------------------------
-- {{{ Keys/Button bindings
keys' :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
keys' conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
    -- launching and killing programs
    [ ((modMask,                 xK_t     ), spawn $ XMonad.terminal conf)
    , ((modMask .|. shiftMask,   xK_t     ), spawn "urxvt -title urxvt-float")
    , ((modMask .|. controlMask, xK_t     ), spawn "tmux_session.sh")
    , ((modMask,                 xK_r     ), spawn "dmenu_run -fn \"-*-Terminus-regular-r-normal-*-12-*-*-*-*-*-*-*\" -nb \"#131313\" -nf \"#888888\" -sb \"#2A2A2A\" -sf \"#3579A8\"")
    --, ((modMask,                 xK_b     ), spawn "chromium --incognito")
    , ((modMask,                 xK_b     ), spawn "firefox")
    , ((modMask,                 xK_e     ), spawn "empathy")
    , ((modMask,                 xK_v     ), spawn "variety --selector")
    , ((modMask .|. shiftMask,   xK_m     ), spawn "urxvt -title urxvt-float -e ncmpcpp")
    , ((modMask .|. shiftMask,   xK_r     ), spawn "urxvt -title urxvt-float -e rtorrent")
    , ((modMask .|. shiftMask,   xK_i     ), spawn "urxvt -title urxvt-float -e screen irssi")
    , ((modMask,                 xK_c     ), kill)
    , ((modMask,                 xK_x     ), xmonadPrompt myXPConfig)
    , ((modMask,                 xK_s     ), shellPrompt myXPConfig)
    , ((modMask,                 xK_a     ), spawn "~/bin/stalonetray.sh")

    -- notes
    , ((modMask,                 xK_n     ), do
          spawn("echo -n \"[`date '+%Y-%m-%d %H:%M:%S'`] \">>"++"~/NOTES")
          appendFilePrompt myXPConfig "~/NOTES")
    , ((modMask .|. shiftMask,   xK_n     ), spawn "urxvt -title urxvt-float -e emacs -nw ~/NOTES")

    -- layouts
    , ((modMask,                 xK_space ), sendMessage NextLayout)
    , ((modMask .|. shiftMask,   xK_space ), setLayout $ XMonad.layoutHook conf)
    , ((modMask .|. shiftMask,   xK_b     ), sendMessage ToggleStruts)

    -- floating layer stuff
    , ((modMask,                 xK_f     ), withFocused $ windows . W.sink)

    -- refresh
    , ((modMask .|. controlMask, xK_r     ), refresh)
    , ((modMask .|. controlMask, xK_w     ), withFocused toggleBorder)

    -- focus
    , ((modMask,                 xK_Tab   ), windows W.focusDown)
    , ((modMask,                 xK_j     ), windows W.focusDown)
    , ((modMask,                 xK_k     ), windows W.focusUp)
    , ((modMask,                 xK_m     ), windows W.focusMaster)
    , ((modMask .|. controlMask, xK_p     ), promote)

    -- swapping
    , ((modMask .|. controlMask, xK_Return), windows W.swapMaster)
    , ((modMask .|. controlMask, xK_j     ), windows W.swapDown  )
    , ((modMask .|. controlMask, xK_k     ), windows W.swapUp    )

    -- increase or decrease number of windows in the master area
    , ((modMask .|. controlMask, xK_h     ), sendMessage (IncMasterN 1))
    , ((modMask .|. controlMask, xK_l     ), sendMessage (IncMasterN (-1)))

    -- resizing
    , ((modMask,                 xK_h     ), sendMessage Shrink)
    , ((modMask,                 xK_l     ), sendMessage Expand)
    , ((modMask .|. shiftMask,   xK_h     ), sendMessage MirrorShrink)
    , ((modMask .|. shiftMask,   xK_l     ), sendMessage MirrorExpand)

    -- quit, or restart
    , ((modMask .|. shiftMask,   xK_q     ), io (exitWith ExitSuccess))
--    , ((modMask              ,   xK_q     ), restart "xmonad" True)
    , ((modMask,                 xK_q     ), spawn "killall dzen2 && xmonad --recompile && xmonad --restart")

    -- Alsa Multimedia Control
    , ((0, 0x1008ff11), spawn "/home/alex/.xmonad/scripts/volctl down"  )
    , ((0, 0x1008ff13), spawn "/home/alex/.xmonad/scripts/volctl up"    )
    , ((0, 0x1008ff12), spawn "/home/alex/.xmonad/scripts/volctl toggle")

    -- Brightness Control
    , ((0, 0x1008ff03), spawn "xbacklight -dec 20")
    , ((0, 0x1008ff02), spawn "xbacklight -inc 20")

    -- Switching next / prev workspace
    , ((modMask .|. controlMask, xK_Left), prevWS)
    , ((modMask .|. controlMask, xK_Right), nextWS)

    -- add / remove workspaces
    , ((modMask .|. controlMask, xK_a), DW.addWorkspacePrompt myXPConfig)
    , ((modMask .|. controlMask, xK_c), DW.withWorkspace myXPConfig (windows . copy))
    , ((modMask .|. controlMask, xK_d), DW.removeEmptyWorkspace)
    , ((modMask .|. controlMask, xK_n), DW.renameWorkspace myXPConfig)
    , ((modMask .|. controlMask, xK_p), workspacePrompt myXPConfig (windows . W.shift))
    , ((modMask .|. controlMask, xK_g), gotoMenu)

    ]
    -- mod-[1..9]       %! Switch to workspace N
    -- mod-shift-[1..9] %! Move client to workspace N
    ++
    zip (zip (repeat modMask) [xK_F1..xK_F9]) (map (DW.withNthWorkspace W.greedyView) [0..])
    ++
    zip (zip (repeat (modMask .|. shiftMask)) [xK_F1..xK_F9]) (map (DW.withNthWorkspace W.shift) [0..])
    -- mod-[1..9] %! Switch to workspace N
    -- mod-shift-[1..9] %! Move client to workspace N
    -- ++
    -- [((m .|. modMask, k), windows $ f i)
    --     | (i, k) <- zip (XMonad.workspaces conf) [xK_F1 .. xK_F9]
    --     , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
-- }}}
