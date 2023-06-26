export class StringUtils {
    public static isEmpty(input:string) {
        return (input.replace(/\s/g, "").length > 0 ? false : true);
    }
}