import AsyncStorage from '@react-native-async-storage/async-storage';
import RNFetchBlob from 'rn-fetch-blob';
import store from '..';
import { isNotNull } from '../../utils/CoreUtil';
import { getHeaders } from './ApiService';

const FILE_TEMP_STORAGE_KEY = 'SNAP_CRESCENT_TEMPORARY_FILES';
const FILE_SESSION_KEY = 'SNAP_CRESCENT_FILES_SESSION';

export const FILE_RESPONSE_TYPE = {
    BASE64: 'base64',
    PATH: 'path'
};

export const fetchFile = (url, config) => {

    const configOption =
        config?.responseType == FILE_RESPONSE_TYPE.BASE64
            ? {}
            : {
                fileCache: true,
                session: FILE_SESSION_KEY
            };

    return RNFetchBlob
        .config(configOption)
        .fetch('GET', getUrl(url), getHeaders())
        .then((res) => {
            if (config?.responseType == FILE_RESPONSE_TYPE.BASE64) {
                const base64Resp = res.base64();
                return `data:${config.mimeType};base64,${base64Resp}`;
            } else {
                const filePath = res.path();
                addTempPathInStorage(filePath);
                return Platform.OS === 'android' ? 'file://' + filePath : '' + filePath;
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

export const clearTemporaryStorage = () => {
    AsyncStorage.getItem(FILE_TEMP_STORAGE_KEY).then(item => {
        if (isNotNull(item)) {
            const filePaths = JSON.parse(item);
            filePaths.forEach(path => {
                RNFetchBlob.fs.unlink(path);
            });

            AsyncStorage.removeItem(FILE_TEMP_STORAGE_KEY);
        }
    });
}

const addTempPathInStorage = (filePath) => {
    AsyncStorage.getItem(FILE_TEMP_STORAGE_KEY).then(item => {
        const existsingItems = isNotNull(item) ? JSON.parse(item) : [];
        existsingItems.push(filePath);
        AsyncStorage.setItem(FILE_TEMP_STORAGE_KEY, JSON.stringify(filePath));
    });
}

const getUrl = (url) => {
    const serverUrl = store.getState().serverUrl;
    return serverUrl + '/' + url;
}