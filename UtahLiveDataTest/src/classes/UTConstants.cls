global without sharing class UTConstants {
	global static final String FILE_BATCH_MSP = 'MSP';
	global static final String FILE_BATCH_FED_FORMULA = 'FedFormula';
	global static final String FILE_BATCH_STATE_FORMULA = 'StateFormula';
	global static final String FILE_BATCH_APP12 = 'App12';
	global static final String FILE_BATCH_LSA = 'LSA';
	global static final String FILE_BATCH_LSNA = 'LSNA';
	global static final String FILE_BATCH_FED_COMPETE = 'FedCompete';
	global static final String FILE_BATCH_STATE_COMPETE = 'StateCompete';
	global static final Map<string, string> FILE_BATCH_FULL_NAMES = new Map<string, string> {
		'MSP' => 'MSP',
		'LSA' => 'Lump-Sum-App',
		'LSNA' => 'Lump-Sum-No-App',
		'FedFormula' => 'Fed-Formula',
		'StateFormula' => 'State-Formula',
		'StateCompete' => 'State-Competitive',
		'FedCompete' => 'Fed-Competitive',
		'App12' => 'Application 1/12th'
	};
	global Map<String, Map<String, Map<String, Map<String, String>>>> approveAndRejectBtnText = new Map<String, Map<String, Map<String, Map<String, String>>>>();

	global UTConstants() {

		//Text for MSP
		Map<String, String> MSPProcessedCreateAndAmend = new Map<String, String>();
		MSPProcessedCreateAndAmend.put('Approve', 'Approve');
		MSPProcessedCreateAndAmend.put('Reject', 'Reject');
		Map<String, String> MSPApprovedCreate = new Map<String, String>();
		MSPApprovedCreate.put('Approve', 'Create Awards');
		MSPApprovedCreate.put('Reject', 'Reject');
		Map<String, String> MSPApprovedAmend = new Map<String, String>();
		MSPApprovedAmend.put('Approve', 'Amend Awards');
		MSPApprovedAmend.put('Reject', 'Reject');

		Map<String, Map<String, String>> MSPProcessed = new Map<String, Map<String, String>>();
		MSPProcessed.put('Create', MSPProcessedCreateAndAmend);
		MSPProcessed.put('Amend', MSPProcessedCreateAndAmend);
		Map<String, Map<String, String>> MSPApproved = new Map<String, Map<String, String>>();
		MSPApproved.put('Create', MSPApprovedCreate);
		MSPApproved.put('Amend', MSPApprovedAmend);

		Map<String, Map<String, Map<String, String>>> MSPMap = new Map<String, Map<String, Map<String, String>>>();
		MSPMap.put('Processed', MSPProcessed);
		MSPMap.put('Sent for Activation', MSPApproved);

		//approveAndRejectBtnText.put('MSP', MSPMap);
		//approveAndRejectBtnText.put('FedFormula', MSPMap);

		approveAndRejectBtnText.put('MSP', getSettings('Approve', 'Reject', 'Create Awards', 'Amend Awards'));
		approveAndRejectBtnText.put('FedFormula', getSettings('Approve', 'Reject', 'Create Applications', 'Make Amendments'));

		//Text for Fed

	}

	private Map<String, Map<String, Map<String, String>>> getSettings(String approve, String reject, String createEntity, String amendEntity) {
		Map<String, String> MSPProcessedCreateAndAmend = new Map<String, String>();
		MSPProcessedCreateAndAmend.put('Approve', approve);
		MSPProcessedCreateAndAmend.put('Reject', reject);
		Map<String, String> MSPApprovedCreate = new Map<String, String>();
		MSPApprovedCreate.put('Approve', createEntity);
		MSPApprovedCreate.put('Reject', reject);
		Map<String, String> MSPApprovedAmend = new Map<String, String>();
		MSPApprovedAmend.put('Approve', amendEntity);
		MSPApprovedAmend.put('Reject', reject);

		Map<String, Map<String, String>> MSPProcessed = new Map<String, Map<String, String>>();
		MSPProcessed.put('Create', MSPProcessedCreateAndAmend);
		MSPProcessed.put('Amend', MSPProcessedCreateAndAmend);
		Map<String, Map<String, String>> MSPApproved = new Map<String, Map<String, String>>();
		MSPApproved.put('Create', MSPApprovedCreate);
		MSPApproved.put('Amend', MSPApprovedAmend);

		Map<String, Map<String, Map<String, String>>> MSPMap = new Map<String, Map<String, Map<String, String>>>();
		MSPMap.put('Processed', MSPProcessed);
		MSPMap.put('Sent for Activation', MSPApproved);
		return MSPMap;
	}


}