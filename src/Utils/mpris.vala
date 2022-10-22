/* 
 * Copyright 2022 Fyra Labs
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Victrola {
    [DBus (name = "org.mpris.MediaPlayer2.Player")]
    public class MprisPlayer : Object {
        [DBus (visible = false)]
        private unowned Application _app;
        private unowned DBusConnection _connection;

        public MprisPlayer (Application app, DBusConnection connection) {
            _app = app;
            _connection = connection;

            app.index_changed.connect (on_index_changed);
            app.song_changed.connect (on_song_changed);
            app.song_tag_parsed.connect (on_song_tag_parsed);
            app.player.state_changed.connect (on_state_changed);
        }

        public bool can_go_next {
            get {
                return _app.current_item < (int) _app.song_list.get_n_items () - 1;
            }
        }

        public bool can_go_previous {
            get {
                return _app.current_item > 0;
            }
        }

        public bool can_play {
            get {
                return _app.song_list.get_n_items () > 0;
            }
        }

        public void next () throws Error {
            _app.play_next ();
        }

        public void previous () throws Error {
            _app.play_previous ();
        }

        public void play_pause () throws Error {
            _app.play_pause();
        }

        private void on_index_changed (int index, uint size) {
            send_property ("CanGoNext", can_go_next);
            send_property ("CanGoPrevious", can_go_previous);
            send_property ("CanPlay", can_play);
        }

        private void on_song_changed (Song song) {
            send_meta_data (song);
        }

        private void on_song_tag_parsed (Song song) {
            send_meta_data (song);
        }

        private void on_state_changed (Gst.State state) {
            send_property ("PlaybackStatus", state == Gst.State.PLAYING ? "Playing" : "Stopped");
        }

        internal void send_meta_data (Song song) {
            var data = new HashTable<string, Variant> (str_hash, str_equal);
            string[] artist = { song.artist };
            data.insert ("xesam:artist", artist);
            data.insert ("xesam:title", song.title);
            send_property ("Metadata", data);
        }

        private void send_property (string name, Variant variant) {
            var invalid = new VariantBuilder (new VariantType ("as"));
            var builder = new VariantBuilder (VariantType.ARRAY);
            builder.add ("{sv}", name, variant);

            try {
                _connection.emit_signal (
                    null,
                    "/org/mpris/MediaPlayer2",
                    "org.freedesktop.DBus.Properties",
                    "PropertiesChanged",
                    new Variant (
                        "(sa{sv}as)",
                        "org.mpris.MediaPlayer2.Player",
                        builder,
                        invalid
                    )
                );
            } catch (Error e) {
                warning ("Send MPRIS property failed: %s\n", e.message);
            }
        }
    }

    [DBus (name = "org.mpris.MediaPlayer2")]
    public class MprisRoot : Object {
        public bool can_quit {
            get {
                return true;
            }
        }

        public bool can_raise {
            get {
                return true;
            }
        }

        public bool has_track_list {
            get {
                return false;
            }
        }

        public string desktop_entry {
            get {
                return Config.APP_ID;
            }
        }

        public string identity {
            get {
                return Config.APP_ID;
            }
        }

        public string[] supported_uri_schemes {
            owned get {
                return {"file", "smb"};
            }
        }

        public string[] supported_mime_types {
            owned get {
                return {"audio"};
            }
        }

        public void quit () throws Error {
            GLib.Application.get_default ()?.quit ();
        }

        public void raise () throws Error {
            GLib.Application.get_default ()?.activate ();
        }
    }
}
