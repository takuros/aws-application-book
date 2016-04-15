package jp.co.app.aws;

import java.util.ArrayList;

public class SampleListType  {
    public ArrayList<Item> Items;

    public class Item{
        public String Name;
        public long Price;
        public long ItemID;
    }
}
