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

int main (string[] args) {
    Intl.bindtextdomain ("co.tauos.Victrola", Config.LOCALEDIR);
    Intl.bind_textdomain_codeset ("co.tauos.Victrola", "UTF-8");
    Intl.textdomain ("co.tauos.Victrola");

    Environment.set_prgname ("co.tauos.Victrola");
    Environment.set_application_name (_("Victrola"));

    Victrola.GstPlayer.init (ref args);

    var app = new Victrola.Application ();
    return app.run (args);
}