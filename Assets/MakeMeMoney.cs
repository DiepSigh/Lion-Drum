using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Advertisements;

public class MakeMeMoney : MonoBehaviour
{

    string gameID = "3744029";
    public string placementID = "bannerPlacement";
    public bool testMode = true;

    void Start () {
        Advertisement.Initialize(gameID, testMode);
        StartCoroutine(ShowBannerWhenInitialized());
    }

    IEnumerator ShowBannerWhenInitialized () {
        while (!Advertisement.isInitialized) {
            yield return new WaitForSeconds(0.5f);
        }

        Advertisement.Banner.SetPosition (BannerPosition.TOP_CENTER);
        Advertisement.Banner.Show (placementID);
        
    }
}
