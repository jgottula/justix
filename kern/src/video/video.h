#ifndef JGSYS_KERN_VIDEO_VIDEO
#define JGSYS_KERN_VIDEO_VIDEO

#ifndef __ASSEMBLY__


void video_set_cur(uint16_t cur);
void video_clear_screen(void);

#endif

%ifndef jgsys_kern_video_video
extern video_set_cur
extern video_clear_screen
%endif

#endif
