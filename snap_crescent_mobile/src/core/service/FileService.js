import RNFetchBlob from "react-native-fetch-blob";
import store from "..";
import { getHeaders } from "./ApiService";

export function downloadFile(url, params) {
    const { config, fs } = RNFetchBlob;
    const filePath = fs.dirs.PictureDir + '/' + params.name;

    const DOWNLOAD_FILE_OPTIONS = {
        fileCache: true,
        addAndroidDownloads: {
            useDownloadManager: true, // setting it to true will use the device's native download manager and will be shown in the notification bar.
            notification: true,
            title: 'Snap Crescent',
            description: `Downloading ${params.name}`,
            path: filePath
        }
    };

    return config(DOWNLOAD_FILE_OPTIONS)
        .fetch('GET',
            getUrl(url),
            getHeaders())
        .then(res => {
            return res;
        }).catch(errorMessage => {
            alert(errorMessage);
        });
}

export const fetchFile = (url, params) => {
    return RNFetchBlob
        .fetch('GET', getUrl(url), getHeaders())
        .then(res => {
            return res.base64();
        }).catch(errorMessage => {
            alert(errorMessage);
        });
}

const getUrl = (url) => {
    const serverUrl = store.getState().serverUrl;
    return serverUrl + '/' + url;
}