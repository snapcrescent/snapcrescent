import RNFetchBlob from 'rn-fetch-blob';
import store from '..';
import { getHeaders } from './ApiService';

export const FILE_RESPONSE_TYPE = {
    BASE64: 'base64',
    PATH: 'path'
}

const getUrl = (url) => {
    const serverUrl = store.getState().serverUrl;
    return serverUrl + '/' + url;
}

export const fetchFile = (url, config) => {

    const configOption =
        config?.responseType == FILE_RESPONSE_TYPE.BASE64
            ? {}
            : { fileCache: true };

    return RNFetchBlob
        .config(configOption)
        .fetch('GET', getUrl(url), getHeaders())
        .then((res) => {
            if (config?.responseType == FILE_RESPONSE_TYPE.BASE64) {
                const base64Resp = res.base64();
                return `data:${config.mimeType};base64,${base64Resp}`;
            } else {
                return Platform.OS === 'android' ? 'file://' + res.path() : '' + res.path();
            }
        });
}

export const downloadFile = (url, config) => {

    const configOption = {
        fileCache: true,
        addAndroidDownloads: {
            useDownloadManager: true,
            notification: true,
            title: config.fileName,
            description: 'Downloading file from Snap Crescent.',
            mime: config.mimeType,
            mediaScannable: true,
            path: config.fileStoragePath
        }
    };

    return RNFetchBlob
        .config(configOption)
        .fetch('GET', getUrl(url), getHeaders())
        .then((res) => {
            return res;
        });
}