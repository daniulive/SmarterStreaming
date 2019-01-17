//
//  nt_common_media_define.h
//  nt_common_media_define
//
//  GitHub: https://github.com/daniulive/SmarterStreaming
//  website: https://www.daniulive.com
//
//  Created by daniulive on 17/6/18.
//  Copyright © 2014~2019 daniulive. All rights reserved.
//

#ifndef NT_COMMON_MEDIA_DEFINE_H_
#define NT_COMMON_MEDIA_DEFINE_H_


#ifdef __cplusplus
extern "C"{
#endif

	typedef enum _NT_MEDIA_CODEC_ID
	{
		NT_MEDIA_CODEC_ID_NONE = 0,

		NT_MEDIA_CODEC_ID_VIDEO_BASE,
		NT_MEDIA_CODEC_ID_H264 = NT_MEDIA_CODEC_ID_VIDEO_BASE,
		NT_MEDIA_CODEC_ID_H265,


		NT_MEDIA_CODEC_ID_AUDIO_BASE = 0x10000,
		NT_MEDIA_CODEC_ID_PCMA = NT_MEDIA_CODEC_ID_AUDIO_BASE,
		NT_MEDIA_CODEC_ID_PCMU,
		NT_MEDIA_CODEC_ID_AAC,
		NT_MEDIA_CODEC_ID_SPEEX,
		NT_MEDIA_CODEC_ID_SPEEX_NB,
		NT_MEDIA_CODEC_ID_SPEEX_WB,
		NT_MEDIA_CODEC_ID_SPEEX_UWB,

	} NT_MEDIA_CODEC_ID;


#ifdef __cplusplus
}
#endif

#endif /* NT_COMMON_MEDIA_DEFINE_H_ */
