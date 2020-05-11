Set-StrictMode -Version Latest 
class ProjectExt: Project {    
    ProjectExt([string] $subscriptionId, [SVTResource] $svtResource): Base($subscriptionId, $svtResource) {
    }

    hidden [ControlResult] CheckSetQueueTime([ControlResult] $controlResult) {
        if ($this.PipelineSettingsObj) {
            
            if ($this.PipelineSettingsObj.enforceSettableVar.enabled -eq $true ) {
                $controlResult.AddMessage([VerificationResult]::Failed, "Only limited variables can be set at queue time. It is set as '$($this.PipelineSettingsObj.enforceSettableVar.orgEnabled)' at organization scope.");
            }
            else {
                $controlResult.AddMessage([VerificationResult]::Passed, "All variables can be set at queue time. It is set as '$($this.PipelineSettingsObj.enforceSettableVar.orgEnabled)' at organization scope.");
            }       
        }
        else {
            $controlResult.AddMessage([VerificationResult]::Manual, "Pipeline settings object could not be fetched due to insufficient permissions at project scope.");
        }
        return $controlResult
    }

    hidden [ControlResult] CheckPrivateProjects([ControlResult] $controlResult)
	{
        $apiURL = $this.ResourceContext.ResourceId;
        $responseObj = [WebRequestHelper]::InvokeGetWebRequest($apiURL);
        if([Helpers]::CheckMember($responseObj,"visibility"))
        {
            if($responseObj.visibility -eq "Private")
            {
                $controlResult.AddMessage([VerificationResult]::Failed,
                                                "Project visibility is set to $($responseObj.visibility)."); 

            }
            else {
                $controlResult.AddMessage([VerificationResult]::Passed,
                                                "Project visibility is set to $($responseObj.visibility).");
            }
        }
        $controlResult.SetStateData("Project visibility is set to ", $responseObj.visibility);
        return $controlResult;
    }
   
}