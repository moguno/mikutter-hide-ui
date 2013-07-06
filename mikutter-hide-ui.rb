# -*- coding: utf-8 -*-

Plugin.create :test do
  on_window_created do |i_window|
    begin
      # メインウインドウを取得
      window_tmp = Plugin.filtering(:gui_get_gtk_widget,i_window)

      if (window_tmp == nil) || (window_tmp[0] == nil) then
        next
      end

      window = window_tmp[0]
      prev_pos = nil
      monitering = false

      active = true

      # 終了モニタ
      monitor = lambda {
        if monitering
          next
        end

        monitering = true

        if !mouse_in_window?(window)
          furo_futa(window, false)
        else
          Reserver.new(1, &monitor)
        end

        monitering = false
      }

      window.ssc("enter-notify-event") {
        if active
          furo_futa(window, true)
        end

        # 消去モニタ
        monitor.call

        false
      }

      window.ssc("focus-in-event"){
        active = true

        # 表示する
        furo_futa(window, true)

        # 消去モニタ
        monitor.call

        false
      }

      window.ssc("focus-out-event"){
        active = false

        false
      }

    rescue => e
      puts e
      puts e.backtrace
    end
  end


  def mouse_in_window?(window)
    size = window.window.size
#    pos = window.screen.root_window.pointer
    pos = ::Gdk::Display.default.pointer

    (((pos[1] >= 0) && (pos[1] <= size[0])) && ((pos[2] >= 0) && (pos[2] <= size[1])))
  end


  def furo_futa(window, show)
    begin
      result = get_all_widgets(window, ::Gtk::Notebook)

      result.each { |notebook|
        notebook.show_tabs = show
      }

      result = get_all_widgets(window, ::Gtk::PostBox)

      result.each { |postbox|
        if show
          postbox.show_all
        else
          postbox.hide_all
        end
      }
    rescue => e
      puts e
      puts e.backtrace
    end 
  end


  def get_all_widgets(root, klass)
    proc = lambda { |widget|
      result = []

      begin
        widget.each_forall { |child|
          if child.is_a?(klass)
            result << child
          end

          if child.is_a?(::Gtk::Container)
            result += proc.call(child)
          end
        }
      rescue => e
      end

      result
    }

    proc.call(root)
  end
end
