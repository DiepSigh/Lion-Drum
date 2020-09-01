using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UIToggle : MonoBehaviour
{

    public int value;
    public Text instrumentText;
    public GameObject instrumentButton;

    public GameObject sideImage;
    public GameObject drumImage;
    public GameObject cymbalImage;
    public GameObject cymbalStopImage;
    public GameObject gongImage;
    public GameObject gongStopImage;

    public GameObject aboutImage;
    public GameObject recordButton;
    public GameObject playButton;

    // Start is called before the first frame update
    void Start()
    {
        value = 0;
        instrumentText.text = "Drum";
        aboutImage.SetActive(false);
    }

    public void changeInstrument(){
        value++;
        if (value==3){
            Start();
            sideImage.SetActive(true);
            drumImage.SetActive(true);
            gongImage.SetActive(false);
            gongStopImage.SetActive(false);
            RecordOn();
        }else if (value==2){
            instrumentText.text = "Gong";
            gongImage.SetActive(true);
            gongStopImage.SetActive(true);
            cymbalImage.SetActive(false);
            cymbalStopImage.SetActive(false);
        }else{ //if value == 1
            instrumentText.text = "Cymbals";
            cymbalImage.SetActive(true);
            cymbalStopImage.SetActive(true);
            sideImage.SetActive(false);
            drumImage.SetActive(false);
            RecordOff();
        }
    }

    public void InstrumentOff(){
        instrumentButton.SetActive(false);
    }

    public void InstrumentOn(){
        instrumentButton.SetActive(true);
    }

    public void ToggleOff(){
        aboutImage.SetActive(false);
    }

    public void ToggleOn(){
        aboutImage.SetActive(true);
    }

    public void RecordOff(){
        recordButton.SetActive(false);
    }

    public void RecordOn(){
        recordButton.SetActive(true);
    }

    public void PlayOff(){
        playButton.SetActive(false);
    }

    public void PlayOn(){
        playButton.SetActive(true);
    }
}
