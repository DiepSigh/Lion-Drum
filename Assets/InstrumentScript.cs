using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class InstrumentScript : MonoBehaviour
{

    public int value;
    public Text instrumentText;

    public GameObject sideImage;
    public GameObject drumImage;
    public GameObject cymbalImage;
    public GameObject gongImage;

    // Start is called before the first frame update
    void Start()
    {
        value = 0;
        instrumentText.text = "Drum";
    }

    public void changeInstrument(){
        value++;
        if (value==3){
            Start();
            sideImage.SetActive(true);
            drumImage.SetActive(true);
            gongImage.SetActive(false);
        }else if (value==2){
            instrumentText.text = "Gong";
            gongImage.SetActive(true);
            cymbalImage.SetActive(false);
        }else{ //if value == 1
            instrumentText.text = "Cymbals";
            cymbalImage.SetActive(true);
            sideImage.SetActive(false);
            drumImage.SetActive(false);
        }
    }
}
