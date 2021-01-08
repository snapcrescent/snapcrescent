import { getData } from "./ApiService";

const IMAGE_URL = 'photo';

export const searchImage = (searchParams) => {
    searchParams = {
        page: 0,
        size: 50,
        ...searchParams
    };
    return getData(IMAGE_URL, searchParams);
}