/* justix
 * (c) 2013 Justin Gottula
 * The source code of this project is distributed under the terms of the
 * simplified BSD license. See the LICENSE file for details.
 */

#ifndef JUSTIX_KERN_VIDEO_VIDEO
#define JUSTIX_KERN_VIDEO_VIDEO

#ifndef __ASSEMBLY__

void video_set_cur(uint16_t cur);
void video_clear_screen(void);

#endif

%ifndef justix_kern_video_video
extern video_set_cur
extern video_clear_screen
%endif

#endif
