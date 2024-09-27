package com.gdal;

import org.gdal.gdal.Dataset;
import org.gdal.gdal.TranslateOptions;
import org.gdal.gdal.gdal;
import org.gdal.gdalconst.gdalconst;

import java.util.Vector;

public class gdal_translate {
    public static void main(String[] args) {
        gdal.AllRegister();

        String src = null, dest = null;
        Vector<String> newArgs = new Vector<>();

        for (int i = 0; i < args.length; i++) {
            if (args[i].charAt(0) == '-') {
                newArgs.add(args[i]);
            } else if (dest == null) {
                dest = args[i]; // Chuỗi đích
            } else if (src == null) {
                src = args[i]; // Chuỗi nguồn
            } else {
                newArgs.add(args[i]);
            }
        }

        // Mở dataset nguồn
        Dataset srcDS = gdal.Open(src, gdalconst.GA_ReadOnly);

        if (srcDS == null) {
            System.err.println("Không thể mở dataset nguồn.");
            System.exit(1);
        }

        // Sử dụng Translate để chuyển đổi dataset sang tệp đích
        Dataset outDS = gdal.Translate(dest, srcDS, new TranslateOptions(newArgs));

        if (outDS == null) {
            System.err.println("Dịch không thành công.");
            System.exit(1);
        }

        System.out.println("Dịch thành công.");
    }
}
