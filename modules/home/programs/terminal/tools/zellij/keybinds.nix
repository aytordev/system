{
  config = {
    programs = {
      zellij = {
        settings = {
          keybinds = {
            locked = {
              _children = [
                {
                  bind = {
                    _args = ["Alt h"];
                    _children = [{MoveFocus._args = ["Left"];}];
                  };
                }
                {
                  bind = {
                    _args = ["Alt j"];
                    _children = [{MoveFocus._args = ["Down"];}];
                  };
                }
                {
                  bind = {
                    _args = ["Alt k"];
                    _children = [{MoveFocus._args = ["Up"];}];
                  };
                }
                {
                  bind = {
                    _args = ["Alt l"];
                    _children = [{MoveFocus._args = ["Right"];}];
                  };
                }
                {
                  bind = {
                    _args = ["Alt n"];
                    _children = [{NewPane = {};}];
                  };
                }
                {
                  bind = {
                    _args = ["Alt v"];
                    _children = [{NewPane._props.direction = "Right";}];
                  };
                }
                {
                  bind = {
                    _args = ["Alt x"];
                    _children = [{CloseFocus = {};}];
                  };
                }
                {
                  bind = {
                    _args = ["Alt z"];
                    _children = [{ToggleFocusFullscreen = {};}];
                  };
                }
                {
                  bind = {
                    _args = ["Alt t"];
                    _children = [{NewTab = {};}];
                  };
                }
                {
                  bind = {
                    _args = ["Ctrl l"];
                    _children = [{GoToNextTab = {};}];
                  };
                }
                {
                  bind = {
                    _args = ["Ctrl h"];
                    _children = [{GoToPreviousTab = {};}];
                  };
                }
                {
                  bind = {
                    _args = ["Alt s"];
                    _children = [{SwitchToMode._args = ["Scroll"];}];
                  };
                }
                {
                  bind = {
                    _args = ["Alt r"];
                    _children = [{SwitchToMode._args = ["RenamePane"];}];
                  };
                }
              ];
            };
            scroll = {
              _children = [
                {
                  bind = {
                    _args = [
                      "j"
                      "Down"
                    ];
                    _children = [{ScrollDown = {};}];
                  };
                }
                {
                  bind = {
                    _args = [
                      "k"
                      "Up"
                    ];
                    _children = [{ScrollUp = {};}];
                  };
                }
                {
                  bind = {
                    _args = [
                      "q"
                      "Esc"
                    ];
                    _children = [{SwitchToMode._args = ["Locked"];}];
                  };
                }
              ];
            };
            renamepane = {
              _children = [
                {
                  bind = {
                    _args = ["Enter"];
                    _children = [{SwitchToMode._args = ["Locked"];}];
                  };
                }
                {
                  bind = {
                    _args = ["Esc"];
                    _children = [
                      {UndoRenamePane = {};}
                      {SwitchToMode._args = ["Locked"];}
                    ];
                  };
                }
              ];
            };
          };
        };
      };
    };
  };
}
