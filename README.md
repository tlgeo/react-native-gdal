# react-native-gdal
/**
 * @brief GDAL Library for Android and iOS
 *
 * This documentation provides an overview of the GDAL (Geospatial Data Abstraction Library) 
 * built specifically for Android and iOS platforms. GDAL is a translator library for raster 
 * and vector geospatial data formats that is released under an open-source license. It provides 
 * a single abstract data model to the calling application for all supported formats.
 *
 * Key Features:
 * - Supports a wide range of raster and vector geospatial data formats.
 * - Provides tools for data manipulation, conversion, and analysis.
 * - Optimized for performance on mobile platforms (Android and iOS).
 * - Includes bindings for various programming languages, including C++.
 *
 * Usage:
 * - Integrate the GDAL library into your Android or iOS application to handle geospatial data.
 * - Utilize the provided APIs to read, write, and transform geospatial data.
 * - Leverage the library's capabilities to perform complex geospatial operations on mobile devices.
 *
 * Dependencies:
 * - Ensure that your development environment is set up for cross-compiling for Android and iOS.
 * - Include necessary dependencies and configurations as per the GDAL build instructions for mobile platforms.
 *
 * For more information, refer to the official GDAL documentation and the specific build instructions 
 * for Android and iOS platforms.
 */

## Installation

```sh
npm install react-native-gdal
```

## Usage


```js
import { ogr2ogr } from 'react-native-gdal';

const result = await ogr2ogr('input.geojson', 'output.shp');
```

## Notes

Currently, only ogr2ogr, ogrinfo and gdalinfo are supported on Android.


## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
