integer face = 4;
string url = "https://calendar.google.com/calendar/embed?src=fallenstarclan%40gmail.com&ctz=America%2FLos_Angeles&showTitle=0&showPrint=0&showCalendars=0";
integer seq = 0;

default
{
    state_entry()
    {
        list options;
        options += 
        [
            PRIM_MEDIA_AUTO_PLAY,TRUE,      // Show this page immediately
            PRIM_MEDIA_AUTO_ZOOM, TRUE,
            PRIM_MEDIA_PERMS_CONTROL, PRIM_MEDIA_PERM_NONE
        ];
            
        options += 
        [
            PRIM_MEDIA_HEIGHT_PIXELS, 1024,   // Height/width of media texture will be
            PRIM_MEDIA_WIDTH_PIXELS, 1024,     //   rounded up to nearest power of 2.
            PRIM_MEDIA_AUTO_SCALE, TRUE
        ];
            
        options += 
        [
            PRIM_MEDIA_WHITELIST, url,
            PRIM_MEDIA_WHITELIST_ENABLE, TRUE,
            PRIM_MEDIA_CURRENT_URL, url,    // The url currently showing
            PRIM_MEDIA_HOME_URL, url       // The url if they hit 'home'
        ];
        
        llSetPrimMediaParams(face, options);
        llSetTimerEvent(60.0 * 10);
    }
    timer()
    {
        llSetPrimMediaParams(face,
            [PRIM_MEDIA_CURRENT_URL, url + "/?r=" + (string)(++seq)]);
    }
}