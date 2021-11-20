import AsyncStorage from "@react-native-async-storage/async-storage";
import RNFetchBlob from "rn-fetch-blob";
import { isNotNull } from "../../utils/CoreUtil";
import { getData } from "./ApiService";
import { downloadFile, fetchFile } from "./FileService";

const PHOTO_URL = 'photo';
const PHOTO_STORAGE_KEY = 'photos';

export const searchPhoto = (searchParams, fetchFromServer = false, overrideStoredPhotos = false, callback) => {
    searchParams = {
        page: 0,
        size: 500,
        sort: 'metadata.createdDate',
        sortDirection: 'asc',
        ...searchParams
    };

    if (!fetchFromServer) {
        return AsyncStorage.getItem(PHOTO_STORAGE_KEY).then(storedObject => {
            if (isNotNull(storedObject)) {
                storedObject = JSON.parse(storedObject);
                if (callback) {
                    callback(storedObject);
                } else {
                    return storedObject;
                }
            } else {
                searchPhotosFromServer(searchParams, true, callback);
            }
        });
    } else {
        return searchPhotosFromServer(searchParams, overrideStoredPhotos, callback);
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

const searchPhotosFromServer = (searchParams, overrideStoredPhotos, callback) => {
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

        if (overrideStoredPhotos) {
            AsyncStorage.removeItem(PHOTO_STORAGE_KEY, () => {
                AsyncStorage.setItem(PHOTO_STORAGE_KEY, JSON.stringify(responseObject));
            });

            if (callback) {
                callback(responseObject);
            }
        } else {
            AsyncStorage.getItem(PHOTO_STORAGE_KEY).then(item => {
                let existingItem = {
                    data: []
                };
                if (isNotNull(item)) {
                    existingItem = JSON.parse(item);
                }

                existingItem.totalElements = responseObject.totalElements;
                existingItem.totalPages = responseObject.totalPages;
                existingItem.data = [...existingItem.data, ...responseObject.data];
                responseObject.data = [...existingItem.data];

                AsyncStorage.setItem(PHOTO_STORAGE_KEY, JSON.stringify(existingItem));
                if (callback) {
                    callback(responseObject);
                }
            });
        }
    });
}