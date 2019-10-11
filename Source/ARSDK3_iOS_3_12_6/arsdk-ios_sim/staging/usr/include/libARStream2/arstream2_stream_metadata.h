/**
 * @file arstream2_stream_metadata.h
 * @brief Parrot Streaming Library - Stream Metadata
 * @date 08/03/2016
 * @author aurelien.barre@parrot.com
 */

#ifndef _ARSTREAM2_STREAM_METADATA_H_
#define _ARSTREAM2_STREAM_METADATA_H_

#ifdef __cplusplus
extern "C" {
#endif /* #ifdef __cplusplus */

#include <inttypes.h>


/**
 * @brief ARSTREAM2 stream untimed metadata.
 */
typedef struct ARSTREAM2_Stream_UntimedMetadata_t
{
    char *friendlyName;                             /**< Friendly name (such as product name or maker + model) */
    char *maker;                                    /**< Product maker */
    char *model;                                    /**< Product model */
    char *modelId;                                  /**< Product model ID (ARSDK 16-bit model ID in hex ASCII) */
    char *serialNumber;                             /**< Device serial number (unique identifier) */
    char *softwareVersion;                          /**< Software name and version */
    char *buildId;                                  /**< Software build ID */
    char *title;
    char *comment;
    char *copyright;
    char *runDate;                                  /**< Run date and time */
    char *runUuid;                                  /**< Run UUID */
    double takeoffLatitude;                         /**< Takeoff latitude (500 means unknown) */
    double takeoffLongitude;                        /**< Takeoff longitude (500 means unknown) */
    float takeoffAltitude;                          /**< Takeoff altitude */
    float pictureHFov;                              /**< Camera horizontal field of view (0 means unknown) */
    float pictureVFov;                              /**< Camera vertical field of view (0 means unknown) */

} ARSTREAM2_Stream_UntimedMetadata_t;


#ifdef __cplusplus
}
#endif /* #ifdef __cplusplus */

#endif /* #ifndef _ARSTREAM2_STREAM_METADATA_H_ */
