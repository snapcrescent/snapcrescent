import AsyncStorage from "@react-native-async-storage/async-storage";
import RNFetchBlob from "rn-fetch-blob";
import { isNotNull } from "../../utils/CoreUtil";
import { getData } from "./ApiService";
import { downloadFile, fetchFile } from "./FileService";

const PHOTO_URL = 'photo';

export const searchPhoto = (searchParams, callback, fetchFromServer = false) => {
    searchParams = { page: 0, size: 500, ...searchParams };

    if (!fetchFromServer) {
        const searchKey = JSON.stringify(searchParams);
        return AsyncStorage.getItem(searchKey).then(storedObject => {
            if (isNotNull(storedObject)) {
                storedObject = JSON.parse(storedObject);
                if (callback) {
                    callback(storedObject);
                } else {
                    return storedObject;
                }
            } else {
                searchPhotosFromServer(searchParams, callback);
            }
        });
    } else {
        return searchPhotosFromServer(searchParams, callback);
    }

}

export const getPhotoById = (photoId, params) => {
    return fetchFile(PHOTO_URL + '/' + photoId, params);
}

export const downloadPhotoById = (photoId, params) => {
    params = {
        ...params,
        fileName: params.name,
        mimeType: 'image/*',
        fileStoragePath: RNFetchBlob.fs.dirs.PictureDir + '/' + params.name
    };

    return downloadFile(PHOTO_URL + '/' + photoId, params);
}

const searchPhotosFromServer = (searchParams, callback) => {
    return getData(PHOTO_URL, searchParams).then(res => {
        const photos = res.content.map((item) => {
            return {
                id: item.id,
                createdDate: item.metadata.createdDate,
                device: item.metadata.model ? item.metadata.model : 'Unknown',
                size: item.metadata.size,
                name: item.metadata.name,
                mimeType: item.metadata.mimeType,
                thumbnailSource: {
                    uri: `data:${item.metadata.mimeType};base64,${item.base64EncodedThumbnail}`
                }
            };
        });

        const responseObject = {
            totalElements: res.totalElements,
            totalPages: res.totalPages,
            data: photos
        };

        AsyncStorage.removeItem(JSON.stringify(searchParams), () => {
            AsyncStorage.setItem(JSON.stringify(searchParams), JSON.stringify(responseObject));
        });

        if (callback) {
            callback(responseObject);
        }
    });
}