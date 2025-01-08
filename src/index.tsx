import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-gdal' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const Gdal = NativeModules.Gdal
  ? NativeModules.Gdal
  : new Proxy(
    {},
    {
      get() {
        throw new Error(LINKING_ERROR);
      },
    }
  );

export function startAccessingSecurityScopedResource(uri: string): boolean {
  if (Platform.OS === 'ios') {
    return Gdal.RNStartAccessingSecurityScopedResource(uri);
  } else {
    console.warn('startAccessingSecurityScopedResource only works on iOS');
    return false;
  }
}

export function getDrivers(): Promise<string[]> {
  return Gdal.getDrivers();
}

export function ogr2ogr(srcPath: string, destPath: string, agrs: string[]): Promise<string> {
  return Gdal.RNOgr2ogr(srcPath, destPath, agrs);
}

export function ogrinfo(srcPath: string, agrs: string[]): Promise<string> {
  return Gdal.RNOgrinfo(srcPath, agrs);
}

export function gdalinfo(srcPath: string, agrs: string[]): Promise<string> {
  return Gdal.RNGdalinfo(srcPath, agrs);
}

export function gdal_translate(srcPath: string, destPath: string, agrs: string[]): Promise<string> {
  return Gdal.RNGdalTranslate(srcPath, destPath, agrs);
}

export function gdal_addo(srcPath: string, overviews: number[]): Promise<string> {
  return Gdal.RNGdalAddo(srcPath, overviews);
}

// You must copy the proj.db file from the assets folder to the app's data folder
export function setAndroidProjLibPath(path: string): void {
  if (Platform.OS === 'android') {
    Gdal.RNSetProjLibPath(path);
  }
  else {
    console.warn('setAndroidProjLibPath only works on Android');
  }
}