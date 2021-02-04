import RNFetchBlob from 'rn-fetch-blob';
import store from '..';
import { getHeaders } from './ApiService';

function getUrl(url) {
    const serverUrl = store.getState().serverUrl;
    return serverUrl + '/' + url;
}

export function fetchFile(url, params) {
    return RNFetchBlob
        .config({
            fileCache: true
        })
        .fetch('GET', getUrl(url), getHeaders())
        .then((res) => {
            // When using a file path as Image source on Android,
            // you must prepend "file://"" before the file path
            return Platform.OS === 'android' ? 'file://' + res.path() : '' + res.path()
        });
}

export function downloadFile(url, params) {
    return RNFetchBlob
        .config({
            fileCache: true,
            // android only options, these options be a no-op on IOS
            addAndroidDownloads: {
                useDownloadManager: true,
                // Show notification when response data transmitted
                notification: true,
                // Title of download notification
                title: params.fileName,
                // File description (not notification description)
                description: 'Downloading file from Snap Crescent.',
                mime: params.mimeType,
                // Make the file scannable  by media scanner
                mediaScannable: true,
                path: params.fileStoragePath
            }
        })
        .fetch('GET', getUrl(url), getHeaders())
        .then((res) => {
            return res;
        });
}