/*
This file is part of ssh2-python.
Copyright (C) 2017-2020 Panos Kittenis

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation, version 2.1.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*/

#include <string.h>

static int CR = '\r';
static int EOL = '\n';

int find_eol(char* data, int* new_pos) {
    unsigned int index;
    char *found;
    found = strchr(data, EOL);
    if (found == NULL) {
        return -1;
    }
    if (strchr(found-1, CR)) {
        found--;
        ++*new_pos;
    }
    index = found - data;
    ++*new_pos;
    return index;
}
